{
  writeShellApplication,
  python3,
  v4l-utils,
}:

# tiny2-setup [fix|follow]
#   fix (default): frame the upper body once, then switch tracking off so the gimbal stays put.
#   follow: keep tracking the upper body.
writeShellApplication {
  name = "tiny2-setup";
  runtimeInputs = [
    python3
    v4l-utils
  ];
  text = ''
    dev=/dev/v4l/by-id/usb-Remo_Tech_Co.__Ltd._OBSBOT_Tiny_2-video-index0

    python3 -I ${./tiny2-ai.py} upperbody
    case "''${1:-fix}" in
      fix)
        sleep 5
        python3 -I ${./tiny2-ai.py} stop
        ;;
      follow) ;;
      *)
        echo "usage: tiny2-setup [fix|follow]" >&2
        exit 1
        ;;
    esac

    v4l2-ctl -d "$dev" -c white_balance_automatic=0 -c white_balance_temperature=5500
  '';
}
