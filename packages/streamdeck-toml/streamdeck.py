#!/usr/bin/env python3
"""Drive an Elgato Stream Deck from a TOML file."""

import io
import re
import string
import subprocess
import sys
import threading
import time
import tomllib
from pathlib import Path
from typing import TYPE_CHECKING, NotRequired, TypedDict

from PIL import Image, ImageDraw, ImageFont, ImageOps
from StreamDeck.DeviceManager import DeviceManager
from StreamDeck.ImageHelpers import PILHelper

if TYPE_CHECKING:
    from collections.abc import Mapping, Sequence

    from StreamDeck.Devices.StreamDeck import StreamDeck

PADDING = 4
FIGURE_SPACE = "\u2007"
LINE_GAP = 0.25  # space between lines, relative to the smaller font size


class VarConfig(TypedDict):
    run: str
    match: NotRequired[str]


class StateConfig(TypedDict, total=False):
    text: str
    bg: str
    fg: str
    image: str


class KeyConfig(TypedDict):
    pos: tuple[int, int]
    text: NotRequired[str]
    bg: NotRequired[str]
    fg: NotRequired[str]
    image: NotRequired[str]
    image_height: NotRequired[float]
    press: NotRequired[str]
    vars: NotRequired[dict[str, str | VarConfig]]
    image_cmd: NotRequired[str]
    interval: NotRequired[float]
    offset: NotRequired[int]
    font: NotRequired[str]
    state: NotRequired[str]
    states: NotRequired[dict[str, StateConfig]]


class Config(TypedDict):
    brightness: NotRequired[int]
    bg: NotRequired[str]
    fg: NotRequired[str]
    font: NotRequired[str]
    row_offsets: NotRequired[list[int]]
    key: NotRequired[list[KeyConfig]]


class Defaults(TypedDict):
    bg: str
    fg: str
    font: str


def font_file(pattern: str) -> str:
    if Path(pattern).is_file():
        return pattern
    return subprocess.run(
        ["fc-match", "-f", "%{file}", pattern], capture_output=True, text=True, check=True
    ).stdout


def load_image(data: bytes) -> Image.Image:
    if data.lstrip()[:5] in (b"<?xml", b"<svg "):
        import cairosvg  # noqa: PLC0415 - only needed for SVG

        data = cairosvg.svg2png(bytestring=data, output_width=512)
    return Image.open(io.BytesIO(data)).convert("RGBA")


type Box = tuple[float, float, float, float]


def ink_box(font_path: str, size: int, line: str) -> tuple[ImageFont.FreeTypeFont, Box]:
    """Font of the given size and the bounding box of the line's ink, relative to its baseline."""
    font = ImageFont.truetype(font_path, size)
    return font, font.getbbox(line, anchor="ls")


def max_size(font_path: str, line: str, width: int, height: int) -> int:
    """Largest font size at which the line's ink fits into width x height."""
    lo, hi = 1, height * 2
    while lo < hi:
        size = (lo + hi + 1) // 2
        left, top, right, bottom = ink_box(font_path, size, line)[1]
        if right - left <= width and bottom - top <= height:
            lo = size
        else:
            hi = size - 1
    return lo


def draw_text(img: Image.Image, text: str, font_path: str, fill: str) -> None:
    """Draw each line as large as fits the width, then shrink all lines until they fit the height.

    Lines are stacked and centered by their ink, so caps-only text sits in the visual middle.
    """
    lines = [line for line in text.splitlines() if line.strip()]
    if not lines:
        return
    width, height = img.size
    draw = ImageDraw.Draw(img)
    sizes = [max_size(font_path, line, width - 2 * PADDING, height - 2 * PADDING) for line in lines]
    while True:
        boxes = [ink_box(font_path, s, line) for s, line in zip(sizes, lines, strict=True)]
        gap = round(LINE_GAP * min(sizes))
        total = sum(b[3] - b[1] for _, b in boxes) + gap * (len(lines) - 1)
        if total <= height - 2 * PADDING or max(sizes) == 1:
            break
        scale = (height - 2 * PADDING) / total
        sizes = [max(1, min(s - 1, int(s * scale))) for s in sizes]

    y = (height - total) / 2
    for line, (font, (left, top, right, bottom)) in zip(lines, boxes, strict=True):
        x = (width - (right - left)) / 2
        draw.text((x - left, y - top), line, font=font, fill=fill, anchor="ls")
        y += bottom - top + gap


type Value = str | int | float


def parse_value(text: str) -> Value:
    """Numbers become int or float so templates can use number formats like {cpu:3d}."""
    for kind in (int, float):
        try:
            return kind(text)
        except ValueError:
            pass
    return text


class TemplateFormatter(string.Formatter):
    """str.format with "?" for unknown variables and digit-wide padding for numbers."""

    def get_value(
        self,
        key: int | str,
        args: Sequence[object],  # noqa: ARG002 - signature of the overridden method
        kwargs: Mapping[str, object],
    ) -> object:
        return kwargs.get(str(key), "?")

    def format_field(self, value: object, format_spec: str) -> str:
        try:
            text = super().format_field(value, format_spec)
        except ValueError:  # e.g. {cpu:3d} while cpu is "?"
            return str(value)
        if isinstance(value, int | float):
            # A space is narrower than a digit; the figure space is exactly as wide.
            text = text.replace(" ", FIGURE_SPACE)
        return text


FORMATTER = TemplateFormatter()


class Var:
    """A command whose output defines one variable, or one per named group of its regex."""

    def __init__(self, name: str, cfg: str | VarConfig) -> None:
        if isinstance(cfg, str):
            cfg = {"run": cfg}
        self.run = cfg["run"]
        self.match = re.compile(cfg["match"], re.DOTALL) if "match" in cfg else None
        self.names = list(self.match.groupindex) if self.match else [name]

    def evaluate(self, timeout: float, cwd: Path) -> dict[str, Value]:
        out = subprocess.run(
            ["sh", "-c", self.run],
            capture_output=True,
            text=True,
            timeout=timeout,
            check=True,
            cwd=cwd,
        ).stdout
        if not self.match:
            return {self.names[0]: parse_value(out.strip())}
        m = self.match.search(out)
        if not m:
            msg = f"{self.match.pattern!r} does not match {out!r}"
            raise ValueError(msg)
        return {name: parse_value(text) for name, text in m.groupdict(default="").items()}


class Key:
    def __init__(
        self, deck: StreamDeck, index: int, cfg: KeyConfig, defaults: Defaults, base_dir: Path
    ) -> None:
        self.deck = deck
        self.index = index
        self.base_dir = base_dir
        # bg, fg, text and image are templates that may refer to variables as {name}.
        self.bg: str = cfg.get("bg", defaults["bg"])
        self.fg: str = cfg.get("fg", defaults["fg"])
        self.font: str = font_file(cfg["font"]) if "font" in cfg else defaults["font"]
        self.text: str = cfg.get("text", "")
        self.image_path: str | None = cfg.get("image")
        self.image: Image.Image | None = None
        self.loaded_path: Path | None = None
        # With text, the image takes this fraction of the key height at the top and the text
        # the rest below. 0 lets both fill the whole key, with the text drawn over the image.
        self.image_height: float = cfg.get("image_height", 0)
        self.press: str | None = cfg.get("press")
        self.vars = [Var(name, var) for name, var in cfg.get("vars", {}).items()]
        self.values: dict[str, Value] = {}
        self.image_cmd: str | None = cfg.get("image_cmd")
        self.interval: float = cfg.get("interval", 10)
        self.offset: int = cfg.get("offset", 0)
        # The state template selects an entry of states, which overrides text, bg, fg and image.
        self.state: str | None = cfg.get("state")
        self.states: dict[str, StateConfig] = cfg.get("states", {})
        self.busy = threading.Lock()
        self.stop = threading.Event()
        self.wake = threading.Event()

    def fill(self, template: str) -> str:
        return FORMATTER.vformat(template, (), self.values)

    def render(self) -> None:
        look: StateConfig = self.states.get(self.fill(self.state), {}) if self.state else {}
        bg = self.fill(look.get("bg", self.bg))
        text = self.fill(look.get("text", self.text))
        image_path = look.get("image", self.image_path)
        img: Image.Image = PILHelper.create_key_image(self.deck, background=bg)
        w, h = img.size
        if image_path:
            path = self.base_dir / Path(self.fill(image_path)).expanduser()
            if path != self.loaded_path:
                self.image = load_image(path.read_bytes())
                self.loaded_path = path
        text_top = 0
        if self.image:
            box = (w, h)
            if text and self.image_height:
                text_top = round(h * self.image_height)
                box = (w - 2 * PADDING, text_top - PADDING)
            pic = ImageOps.contain(self.image, box)
            y = PADDING if text_top else (h - pic.height) // 2
            img.paste(pic, ((w - pic.width) // 2, y), pic)
        if text:
            area = img.crop((0, text_top, w, h))
            draw_text(area, text, self.font, self.fill(look.get("fg", self.fg)))
            img.paste(area, (0, text_top))
        if self.offset:
            # Compensate for parallax between the display and the keycap surface.
            shifted = PILHelper.create_key_image(self.deck, background=bg)
            shifted.paste(img, (0, self.offset))
            img = shifted
        native = PILHelper.to_native_key_format(self.deck, img)
        with self.deck:
            self.deck.set_key_image(self.index, native)

    def on_press(self) -> None:
        press = self.press
        if not press or not self.busy.acquire(blocking=False):
            return

        def run() -> None:
            try:
                subprocess.run(["sh", "-c", press], check=False, cwd=self.base_dir)
            finally:
                self.busy.release()
                self.wake.set()  # show the effect of the press right away

        threading.Thread(target=run, daemon=True).start()

    def show(self) -> None:
        """Render, but only report errors: values from commands can be anything."""
        try:
            self.render()
        except Exception as e:  # noqa: BLE001 - e.g. a variable producing an invalid color
            print(f"key {self.index}: render: {e}", file=sys.stderr)

    def poll(self) -> None:
        timeout = max(self.interval, 5)
        while not self.stop.is_set():
            for var in self.vars:
                try:
                    self.values.update(var.evaluate(timeout, self.base_dir))
                except Exception as e:  # noqa: BLE001 - keep polling whatever the command does
                    print(f"key {self.index}: {var.run!r}: {e}", file=sys.stderr)
                    self.values.update(dict.fromkeys(var.names, "?"))
            if self.image_cmd:
                try:
                    out = subprocess.run(
                        ["sh", "-c", self.image_cmd],
                        cwd=self.base_dir,
                        capture_output=True,
                        timeout=timeout,
                        check=True,
                    ).stdout
                    self.image = load_image(out)
                except Exception as e:  # noqa: BLE001
                    print(f"key {self.index}: {self.image_cmd!r}: {e}", file=sys.stderr)
            self.show()
            self.wake.wait(self.interval)
            self.wake.clear()


def load_keys(deck: StreamDeck, cfg: Config, base_dir: Path) -> dict[int, Key]:
    defaults: Defaults = {
        "bg": cfg.get("bg", "black"),
        "fg": cfg.get("fg", "white"),
        "font": font_file(cfg.get("font", "DejaVu Sans:bold")),
    }
    row_offsets = cfg.get("row_offsets", [])
    rows, cols = deck.key_layout()
    keys: dict[int, Key] = {}
    for kcfg in cfg.get("key", []):
        col, row = kcfg["pos"]
        if not (0 <= col < cols and 0 <= row < rows):
            sys.exit(f"key position {kcfg['pos']} outside {cols}x{rows} deck")
        if row < len(row_offsets):
            kcfg.setdefault("offset", row_offsets[row])
        key = Key(deck, row * cols + col, kcfg, defaults, base_dir)
        keys[key.index] = key
    return keys


def start_keys(keys: dict[int, Key]) -> list[threading.Thread]:
    """Render all keys and start a polling thread for each key with commands."""
    pollers: list[threading.Thread] = []
    for key in keys.values():
        if key.vars or key.image_cmd:
            key.show()  # with all variables "?" until the first poll finishes
            pollers.append(threading.Thread(target=key.poll, daemon=True))
            pollers[-1].start()
        else:
            key.render()
    return pollers


def main() -> None:
    path = Path(sys.argv[1] if len(sys.argv) > 1 else "~/.config/streamdeck/config.toml")
    path = path.expanduser().absolute()
    with path.open("rb") as f:
        cfg: Config = tomllib.load(f)  # ty: ignore[invalid-assignment]

    decks: list[StreamDeck] = DeviceManager().enumerate()
    if not decks:
        sys.exit("no Stream Deck found")
    deck = decks[0]
    deck.open()
    deck.reset()
    deck.set_brightness(cfg.get("brightness", 75))

    keys = load_keys(deck, cfg, path.parent)
    pollers = start_keys(keys)

    def on_key(_deck: StreamDeck, index: int, pressed: bool) -> None:  # noqa: FBT001 - callback signature
        if pressed and index in keys:
            keys[index].on_press()

    deck.set_key_callback(on_key)
    try:
        # The reader thread closes the deck when the device goes away, e.g. when the
        # hub it hangs off powers down with the monitor. It comes back as a new device,
        # so exit and let the service manager restart us to open that one.
        while deck.is_open():
            time.sleep(1)
        sys.exit("Stream Deck disconnected")
    except KeyboardInterrupt:
        pass
    finally:
        for key in keys.values():
            key.stop.set()
            key.wake.set()
        # Pollers must be done before the deck closes, or they print render errors while
        # the interpreter shuts down, which aborts it when they hold the stderr lock.
        for poller in pollers:
            poller.join()
        with deck:
            if deck.is_open():
                deck.reset()
                deck.close()


if __name__ == "__main__":
    main()
