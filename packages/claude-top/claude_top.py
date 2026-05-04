"""Live overview of running Claude Code instances.

Reads ~/.claude/sessions/*.json and renders a table that refreshes
once per second. Busy sessions are green, idle sessions yellow,
waiting sessions red. Quit with Ctrl-C or 'q'.

Pass --on-idle CMD / --on-waiting CMD to run a shell command whenever
any session transitions into the matching state (e.g. --on-idle
play-ready-sound). The "waiting" state is when Claude is blocked on a
permission prompt or other user input.
"""

from __future__ import annotations

import argparse
import curses
import json
import os
import signal
import subprocess
import time
from dataclasses import dataclass
from pathlib import Path

SESSIONS_DIR = Path.home() / ".claude" / "sessions"
REFRESH_SECONDS = 1.0


@dataclass
class Session:
    pid: int
    status: str
    waiting_for: str
    cwd: str
    session_id: str
    updated_at: float
    alive: bool

    @property
    def age_seconds(self) -> float:
        return max(0.0, time.time() - self.updated_at)


def pid_alive(pid: int) -> bool:
    try:
        os.kill(pid, 0)
    except ProcessLookupError:
        return False
    except PermissionError:
        return True
    return True


def _read_session_file(path: Path) -> dict | None:
    # Sessions are rewritten in place, so a read can race with a write
    # and yield empty / truncated JSON. Retry briefly so we don't drop
    # the session — and miss its state transition — for a whole cycle.
    for attempt in range(4):
        try:
            return json.loads(path.read_text())
        except json.JSONDecodeError:
            if attempt == 3:
                return None
            time.sleep(0.02)
        except OSError:
            return None
    return None


def load_sessions() -> list[Session]:
    sessions: list[Session] = []
    if not SESSIONS_DIR.is_dir():
        return sessions
    for path in sorted(SESSIONS_DIR.glob("*.json")):
        data = _read_session_file(path)
        if data is None:
            continue
        pid = int(data.get("pid", 0))
        if not pid:
            continue
        sessions.append(
            Session(
                pid=pid,
                status=str(data.get("status", "?")),
                waiting_for=str(data.get("waitingFor", "") or ""),
                cwd=str(data.get("cwd", "")),
                session_id=str(data.get("sessionId", "")),
                updated_at=float(data.get("updatedAt", 0)) / 1000.0,
                alive=pid_alive(pid),
            )
        )
    sessions.sort(key=lambda s: (not s.alive, s.status, s.pid))
    return sessions


def fmt_age(seconds: float) -> str:
    if seconds < 60:
        return f"{int(seconds)}s"
    if seconds < 3600:
        return f"{int(seconds // 60)}m"
    if seconds < 86400:
        return f"{int(seconds // 3600)}h"
    return f"{int(seconds // 86400)}d"


def shrink(text: str, width: int) -> str:
    if width <= 0:
        return ""
    if len(text) <= width:
        return text
    if width <= 1:
        return text[:width]
    return "…" + text[-(width - 1):]


COLUMNS = [
    ("PID", 8),
    ("STATUS", 9),
    ("AGE", 6),
    ("WAITING-FOR", 22),
    ("CWD", 0),  # 0 = take remaining width
]


def run_transition_command(command: str) -> None:
    try:
        subprocess.Popen(
            command,
            shell=True,
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
            stdin=subprocess.DEVNULL,
            start_new_session=True,
        )
    except OSError:
        pass


def draw(
    stdscr: "curses._CursesWindow",
    on_idle: str | None,
    on_waiting: str | None,
) -> None:
    curses.curs_set(0)
    stdscr.nodelay(True)
    stdscr.timeout(int(REFRESH_SECONDS * 1000))

    curses.start_color()
    curses.use_default_colors()
    curses.init_pair(1, curses.COLOR_YELLOW, -1)  # idle
    curses.init_pair(2, curses.COLOR_RED, -1)     # waiting
    curses.init_pair(3, curses.COLOR_GREEN, -1)   # busy
    curses.init_pair(4, curses.COLOR_BLACK, -1)   # dead/stale
    curses.init_pair(5, curses.COLOR_CYAN, -1)    # header
    DIM = curses.A_DIM

    triggers = {"idle": on_idle, "waiting": on_waiting}
    prev_status: dict[int, str] = {}
    first_pass = True

    while True:
        sessions = load_sessions()

        if not first_pass:
            fired: set[str] = set()
            for s in sessions:
                if not s.alive or s.status in fired:
                    continue
                cmd = triggers.get(s.status)
                if not cmd:
                    continue
                prev = prev_status.get(s.pid)
                if prev is not None and prev != s.status:
                    run_transition_command(cmd)
                    fired.add(s.status)
        # Carry forward last-known status for sessions that briefly
        # vanished (e.g. transient JSON read failure) so the very next
        # cycle still sees a real "prev" and can detect the transition.
        for s in sessions:
            if s.alive:
                prev_status[s.pid] = s.status
        first_pass = False

        height, width = stdscr.getmaxyx()
        stdscr.erase()

        title = f" claude-top — {len(sessions)} session(s) — refresh {REFRESH_SECONDS:g}s — q/Ctrl-C to quit "
        stdscr.addnstr(0, 0, title.ljust(width), width, curses.A_REVERSE)

        # Compute column widths: last column gets the remainder.
        fixed = sum(w for _, w in COLUMNS if w > 0) + (len(COLUMNS) - 1)
        last_w = max(10, width - fixed)
        widths = [w if w > 0 else last_w for _, w in COLUMNS]

        # Header.
        x = 0
        for (name, _), w in zip(COLUMNS, widths):
            stdscr.addnstr(2, x, name.ljust(w), w, curses.color_pair(5) | curses.A_BOLD)
            x += w + 1
        stdscr.hline(3, 0, curses.ACS_HLINE, width)

        # Rows.
        max_rows = height - 5
        for i, s in enumerate(sessions[:max_rows]):
            row = 4 + i
            status = s.status if s.alive else "dead"
            if not s.alive:
                attr = curses.color_pair(4) | DIM
            elif status == "idle":
                attr = curses.color_pair(1)
            elif status == "waiting":
                attr = curses.color_pair(2) | curses.A_BOLD
            elif status == "busy":
                attr = curses.color_pair(3)
            else:
                attr = curses.A_NORMAL

            cells = [
                str(s.pid),
                status,
                fmt_age(s.age_seconds),
                s.waiting_for or "-",
                s.cwd or "-",
            ]
            x = 0
            for cell, w in zip(cells, widths):
                stdscr.addnstr(row, x, shrink(cell, w).ljust(w), w, attr)
                x += w + 1

        if not sessions:
            stdscr.addnstr(4, 0, "No active Claude sessions found.", width, DIM)

        # Avoid the bottom-right cell — writing there triggers a scroll
        # and addnstr returns ERR.
        if width > 1:
            footer = f" {SESSIONS_DIR} "
            stdscr.addnstr(height - 1, 0, footer.ljust(width - 1), width - 1, curses.A_REVERSE)

        stdscr.refresh()

        ch = stdscr.getch()
        if ch in (ord("q"), ord("Q")):
            return


def parse_args(argv: list[str] | None = None) -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        prog="claude-top",
        description="Live overview of running Claude Code instances.",
    )
    parser.add_argument(
        "--on-idle",
        default=None,
        metavar="CMD",
        help=(
            "Shell command to run whenever any session transitions to "
            "idle (e.g. 'play-ready-sound'). Runs detached; stdout/stderr "
            "are discarded."
        ),
    )
    parser.add_argument(
        "--on-waiting",
        default=None,
        metavar="CMD",
        help=(
            "Shell command to run whenever any session transitions to "
            "waiting (Claude is blocked on a permission prompt or other "
            "user input). Runs detached; stdout/stderr are discarded."
        ),
    )
    return parser.parse_args(argv)


def main() -> None:
    args = parse_args()

    signal.signal(signal.SIGINT, lambda *_: (_ for _ in ()).throw(KeyboardInterrupt))
    # Reap finished children automatically so detached commands don't zombify.
    try:
        signal.signal(signal.SIGCHLD, signal.SIG_IGN)
    except (AttributeError, ValueError):
        pass
    try:
        curses.wrapper(draw, args.on_idle, args.on_waiting)
    except KeyboardInterrupt:
        pass


if __name__ == "__main__":
    main()
