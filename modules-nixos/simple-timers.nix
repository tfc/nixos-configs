{ config, lib, ... }:

let
  cfg = config.systemd.simple-timers;

  attrsToTimer = name: value: {
    timerConfig = {
      Unit = "${name}.service";
      inherit (value) OnCalendar;
    };
    wantedBy = [ "timers.target" ];
  };

  attrsToService = name: value: {
    serviceConfig = {
      Type = "oneshot";
      inherit (value) ExecStart;
    };
  };
in

{
  options.systemd.simple-timers = lib.mkOption {
    type = lib.types.attrsOf (
      lib.types.submodule {
        options = {
          OnCalendar = lib.mkOption {
            type = lib.types.str;
          };
          ExecStart = lib.mkOption {
            type = lib.types.str;
          };
        };
      }
    );
    default = { };
    description = "Simple timer wrapper module around systemd.timers to reduce boilerplate";
  };

  config.systemd = {
    timers = builtins.mapAttrs attrsToTimer cfg;
    services = builtins.mapAttrs attrsToService cfg;
  };
}
