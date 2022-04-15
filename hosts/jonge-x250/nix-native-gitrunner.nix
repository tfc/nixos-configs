{ pkgs, ... }:

{
  services.gitlab-runner = {
    enable = true;
    concurrent = 1;
    services.shell = {
      executor = "shell";
      registrationConfigFile = "/var/secrets/gitlab-seven-native";
      tagList = [ "nix-shellexecutor" ];
    };
    extraPackages = with pkgs; [
      # Required stuff
      bash
      coreutils
      git
      gnutar
      gzip
      nettools # hostname
      rsync
    ];
  };
}
