{
  lib,
  osConfig,
  pkgs,
  ...
}:

let
  # obs-websocket runs without authentication, but obs-cmd insists on a
  # password in the URL. The trailing slash makes it an empty one.
  obs-cmd = pkgs.symlinkJoin {
    name = "obs-cmd-wrapped";
    paths = [ pkgs.obs-cmd ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/obs-cmd --set OBS_WEBSOCKET_URL obsws://localhost:4455/
    '';
    inherit (pkgs.obs-cmd) meta;
  };

  obsCmd = lib.getExe obs-cmd;
  date = lib.getExe' pkgs.coreutils "date";

  script =
    name: runtimeInputs: text:
    lib.getExe (pkgs.writeShellApplication { inherit name runtimeInputs text; });

  # Prints the OBS recording state: off, stopped, recording or paused.
  obsRecordingState = script "obs-recording-state" [ obs-cmd ] ''
    status=$(obs-cmd recording status 2>/dev/null) || { echo off; exit; }
    case "$status" in
      *[Pp]aused:\ true*) echo paused ;;
      *[Aa]ctive:\ true*) echo recording ;;
      *) echo stopped ;;
    esac
  '';

  green = "#071c0d";
  blue = "#071124";
  grey = "#5e5c64";
  font = "${pkgs.dejavu_fonts}/share/fonts/truetype/DejaVuSans-Bold.ttf";
  monoFont = "${pkgs.dejavu_fonts}/share/fonts/truetype/DejaVuSansMono-Bold.ttf";

  sceneKey = pos: text: scene: {
    inherit pos text;
    bg = green;
    press = "${obsCmd} scene switch ${scene}";
  };

  obsOff = {
    text = ''
      OBS
      off
    '';
    bg = "#000000";
    fg = grey;
  };

  # Keys are addressed as pos = [ column row ], starting at [ 0 0 ] top left.
  # Every `interval` seconds each command in `vars` runs, and text, bg, fg and
  # image can refer to the results as {name}. A var with `match` defines one
  # variable per named regex group instead. Placeholders take Python format
  # specs: {cpu:3} pads a number to 3 digits, {x:.1f} rounds to one decimal.
  # A key's `state` template selects one of its `states`, which override
  # text, bg, fg and image.
  streamdeckSettings = {
    brightness = 75;
    bg = "#000000";
    fg = "#ffffff";
    inherit font;
    # Shift key content up per row to compensate for the parallax of the keycaps.
    row_offsets = [
      (-4)
      (-3)
      (-2)
    ];

    key = [
      (sceneKey [ 0 0 ] ''
        SPEAKER
        LEFT
      '' "sc-speaker-l")
      (sceneKey [ 1 0 ] ''
        SPEAKER
        RIGHT
      '' "sc-speaker-r")
      (sceneKey [ 1 1 ] ''
        SPEAKER
        FULL
      '' "sc-speaker-full")
      (sceneKey [ 0 1 ] ''
        SCREEN
        ONLY
      '' "sc-nospeaker")

      {
        pos = [
          0
          2
        ];
        bg = blue;
        text = ''
          SCREEN
          SLIDES
        '';
        press =
          script "obs-screen-slides"
            [
              obs-cmd
              pkgs.coreutils
              pkgs.wmctrl
            ]
            ''
              obs-cmd filter enable nest-bg show-pres
              obs-cmd filter enable nest-bg hide-drawing
              sleep 0.4
              wmctrl -s 1
            '';
      }
      {
        pos = [
          1
          2
        ];
        bg = blue;
        text = ''
          DESKTOP
          WORK
        '';
        press =
          script "obs-desktop-work"
            [
              obs-cmd
              pkgs.coreutils
              pkgs.wmctrl
            ]
            ''
              wmctrl -s 2
              sleep 0.4
              obs-cmd filter enable nest-bg hide-pres
              obs-cmd filter enable nest-bg hide-drawing
            '';
      }
      {
        pos = [
          2
          2
        ];
        bg = blue;
        text = ''
          DESKTOP
          DRAW
        '';
        press =
          script "obs-desktop-draw"
            [
              obs-cmd
              pkgs.wmctrl
            ]
            ''
              obs-cmd filter toggle nest-bg show-drawing
              obs-cmd filter enable nest-bg hide-pres
              wmctrl -s 1
            '';
      }

      {
        pos = [
          4
          0
        ];
        press = "${obsCmd} recording toggle-pause";
        interval = 2;
        vars.recording = obsRecordingState;
        state = "{recording}";
        text = ''
          RECORD
          PAUSE
        '';
        bg = "#c64600";
        states = {
          off = obsOff;
          stopped = {
            text = ''
              NOT
              RECORDING
            '';
            bg = "#000000";
            fg = grey;
          };
          recording.text = ''
            PAUSE
            RECORD
          '';
          paused.text = ''
            RESUME
            RECORD
          '';
        };
      }
      {
        pos = [
          4
          1
        ];
        press = "${obsCmd} recording toggle";
        interval = 2;
        vars.recording = obsRecordingState;
        state = "{recording}";
        text = ''
          RECORD
          TOGGLE
        '';
        bg = "#a51d2d";
        states = {
          off = obsOff;
          stopped.text = ''
            START
            RECORD
          '';
          recording.text = ''
            STOP
            RECORD
          '';
          paused.text = ''
            STOP
            RECORD
          '';
        };
      }

      {
        pos = [
          3
          2
        ];
        image = "${./obs-streamdeck/square_logo.png}";
      }
      {
        pos = [
          4
          2
        ];
        image = "${./obs-streamdeck/logo-round.svg}";
        bg = "#9a9996";
      }

      {
        pos = [
          2
          1
        ];
        interval = 5;
        vars.date = "${date} +%d.%m.";
        vars.time = "${date} +%H:%M";
        text = ''
          {date}
          {time}
        '';
      }
      {
        pos = [
          3
          0
        ];
        font = monoFont;
        interval = 2;
        vars.cpu = script "cpu-usage" [ pkgs.coreutils ] ''
          read -r _ u n s i w q sq st _ < /proc/stat
          sleep 1
          read -r _ U N S I W Q SQ ST _ < /proc/stat
          busy=$(( (U + N + S + Q + SQ + ST) - (u + n + s + q + sq + st) ))
          idle=$(( (I + W) - (i + w) ))
          echo $(( 100 * busy / (busy + idle) ))
        '';
        vars.ram = script "ram-usage" [ pkgs.gawk ] ''
          awk '/^MemTotal/ {t = $2} /^MemAvailable/ {a = $2} END {printf "%d", 100 * (t - a) / t}' /proc/meminfo
        '';
        vars.gpu = {
          run =
            script "gpu-usage"
              [
                osConfig.hardware.nvidia.package.bin
                pkgs.gawk
              ]
              ''
                nvidia-smi --query-gpu=utilization.gpu,memory.used,memory.total --format=csv,noheader,nounits \
                  | awk -F', ' '{printf "%d %d", $1, 100 * $2 / $3}'
              '';
          match = ''(?P<gpu>\d+) (?P<vram>\d+)'';
        };
        text = ''
          CPU  {cpu:3}%
          GPU  {gpu:3}%
          RAM  {ram:3}%
          VRAM {vram:3}%
        '';
      }
      {
        pos = [
          3
          1
        ];
        font = monoFont;
        interval = 2;
        vars.net = {
          run =
            script "net-throughput"
              [
                pkgs.coreutils
                pkgs.gawk
                pkgs.iproute2
              ]
              ''
                dev=$(ip route show default | awk '{print $5; exit}')
                s=/sys/class/net/$dev/statistics
                rx=$(cat "$s/rx_bytes") tx=$(cat "$s/tx_bytes")
                sleep 1
                echo $(( $(cat "$s/rx_bytes") - rx )) $(( $(cat "$s/tx_bytes") - tx )) \
                  | numfmt --to=iec --field=1-2
              '';
          match = ''(?P<down>\S+)\s+(?P<up>\S+)'';
        };
        text = ''
          network
          ↑ {up:>4}B/s
          ↓ {down:>4}B/s
        '';
      }
    ];
  };

  streamdeckConfig = (pkgs.formats.toml { }).generate "streamdeck.toml" streamdeckSettings;
in
{
  home.packages = with pkgs; [
    kdePackages.kdenlive
    losslesscut-bin
    shotcut

    obs-cmd
    streamdeck-toml
    wmctrl

    (wrapOBS {
      plugins = with obs-studio-plugins; [
        advanced-scene-switcher
        droidcam-obs
        obs-backgroundremoval
        obs-composite-blur
        obs-gstreamer
        obs-media-controls
        obs-move-transition
        obs-multi-rtmp
        obs-pipewire-audio-capture
        obs-replay-source
        obs-shaderfilter
        obs-teleport
        wlrobs
      ];
    })
  ];

  systemd.user.services.streamdeck-toml = {
    Unit = {
      Description = "Stream Deck driven by streamdeck-toml";
      PartOf = [ "graphical-session.target" ];
      After = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = "${lib.getExe pkgs.streamdeck-toml} ${streamdeckConfig}";
      # SIGINT lets the app blank the deck before it exits.
      KillSignal = "SIGINT";
      Restart = "on-failure";
      RestartSec = 5;
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };
}
