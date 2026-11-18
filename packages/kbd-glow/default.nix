{ writeShellApplication }:

# kbd-glow on [COLOR]   light the whole IQUNIX MQ80 in one solid color
# kbd-glow off          back to the normal look (blue reactive wave)
#
# Talks VIA (QMK raw HID, protocol v11) to the keyboard's interface 1.
# Changes are not saved to EEPROM, so a replug also restores the saved look.
#
# "off" writes a fixed baseline instead of a saved/read-back state: the
# firmware reports a stale hue (0x1c) for the color, so restoring read-back
# values turns the board yellow.
writeShellApplication {
  name = "kbd-glow";
  text = ''
    dev=/dev/input/by-id/usb-RDR_IQUNIX_MQ80_KB-if01-hidraw

    # Normal look. Hue/sat are QMK's 0-255 HSV; brightness is 0-9 on this board.
    base_effect=8
    base_hue=170
    base_sat=255
    base_brightness=5

    usage() {
      echo "usage: kbd-glow on [red|orange|yellow|green|cyan|blue|purple|magenta|white|HUE]" >&2
      echo "       kbd-glow off" >&2
      exit 1
    }

    # VIA id_custom_set_value (0x07) on channel 3 (rgb_matrix).
    # One 33-byte write: report id 0 + 32-byte payload.
    rgb_set() {
      local payload=(0 7 3 "$@") esc="" i
      for ((i = 0; i < 33; i++)); do
        esc+=$(printf '\\x%02x' "''${payload[i]:-0}")
      done
      printf '%b' "$esc" >&3
    }

    [[ -e $dev ]] || { echo "kbd-glow: $dev not found (keyboard unplugged?)" >&2; exit 1; }
    exec 3<>"$dev"

    case "''${1:-}" in
      on)
        sat=255
        case "''${2:-red}" in
          red) hue=0 ;;
          orange) hue=21 ;;
          yellow) hue=43 ;;
          green) hue=85 ;;
          cyan) hue=128 ;;
          blue) hue=170 ;;
          purple) hue=191 ;;
          magenta) hue=213 ;;
          white) hue=0 sat=0 ;;
          *)
            [[ $2 =~ ^[0-9]+$ && $2 -le 255 ]] || usage
            hue=$2
            ;;
        esac
        rgb_set 2 1            # effect: solid color
        rgb_set 4 "$hue" "$sat"
        rgb_set 1 9            # brightness: max
        ;;
      off)
        rgb_set 2 "$base_effect"
        rgb_set 4 "$base_hue" "$base_sat"
        rgb_set 1 "$base_brightness"
        ;;
      *) usage ;;
    esac
  '';
}
