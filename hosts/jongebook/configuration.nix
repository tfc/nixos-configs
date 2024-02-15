{ config, pkgs, lib, ... }:

let
  hostName = "jongebook";
in
{
  environment.systemPackages = with pkgs; [
    git
    nixos-rebuild
    utm
    vim
  ];

  nix.linux-builder = {
    enable = true;
    ephemeral = true;
    maxJobs = 4;
    config = {
      virtualisation = {
        darwin-builder = {
          diskSize = 40 * 1024;
          memorySize = 8 * 1024;
        };
        cores = 6;
      };
    };
  };

  services.nix-daemon.enable = true;
  nix = {
    # Run `softwareupdate --install-rosetta --agree-to-license` first
    extraOptions = ''
      extra-platforms = x86_64-darwin aarch64-darwin
    '';
    settings = {
      auto-optimise-store = true;
      experimental-features = [
        "flakes"
        "nix-command"
        "repl-flake"
      ];
      #sandbox = true; # breaks many builds
      trusted-users = [ "@admin" ];
    };
    nixPath = lib.mkForce [ "nixpkgs=${pkgs.path}" ];
  };

  nixpkgs.config.allowUnfree = true;

  security.pam.enableSudoTouchIdAuth = true;
  programs.bash.enableCompletion = true;

  programs.zsh = {
    enable = true;
    enableBashCompletion = true;
    enableFzfCompletion = true;
    enableFzfGit = true;
    enableFzfHistory = true;
  };

  environment.loginShell = "${pkgs.zsh}/bin/zsh -l";
  environment.variables.SHELL = "${pkgs.zsh}/bin/zsh";

  environment.variables.LANG = "en_US.UTF-8";

  users.users.tfc.home = "/Users/tfc";

  fonts.fontDir.enable = true;
  fonts.fonts = with pkgs; [
    powerline-fonts
  ];

  system.defaults = {
    dock.autohide = true;
    finder.AppleShowAllExtensions = true;
    finder.FXPreferredViewStyle = "clmv";
    loginwindow.LoginwindowText = "nixcademy.com";
    screencapture.location = "~/Pictures/screenshots";
    screensaver.askForPasswordDelay = 10;
  };

  system.defaults.smb.NetBIOSName = hostName;
  networking.hostName = hostName;
  networking.localHostName = hostName;

  system.stateVersion = 4;
}
