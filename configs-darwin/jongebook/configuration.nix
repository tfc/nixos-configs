{
  config,
  pkgs,
  lib,
  flakeInputs,
  self,
  ...
}:

let
  hostName = "jongebook";
in
{
  nixpkgs.hostPlatform = "aarch64-darwin";

  imports = [
    flakeInputs.home-manager.darwinModules.home-manager
  ];

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

  nix = {
    # Run `softwareupdate --install-rosetta --agree-to-license` first
    extraOptions = ''
      extra-platforms = x86_64-darwin aarch64-darwin
    '';
    settings = {
      # This sometimes leads to https://github.com/NixOS/nix/issues/7273
      # auto-optimise-store = true;
      experimental-features = [
        "flakes"
        "nix-command"
      ];
      system-features = [
        "big-parallel"
        "nixos-test"
        "apple-virt"
      ];
      #sandbox = true; # breaks many builds
      trusted-users = [ "@admin" ];
    };
    nixPath = lib.mkForce [ "nixpkgs=${pkgs.path}" ];
    package = pkgs.nixVersions.latest;
  };

  nixpkgs.config.allowUnfree = true;

  security.pam.services.sudo_local.touchIdAuth = true;
  programs.bash.completion.enable = true;

  programs.zsh = {
    enable = true;
    enableBashCompletion = true;
    enableFzfCompletion = true;
    enableFzfGit = true;
    enableFzfHistory = true;
  };

  environment.variables.LANG = "en_US.UTF-8";

  users.users.tfc.home = "/Users/tfc";

  fonts.packages = with pkgs; [
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

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.backupFileExtension = "backup";
  home-manager.users.tfc =
    { ... }:
    {
      home.stateVersion = "23.11";
      programs.home-manager.enable = true;
      imports = with self.homeManagerModules; [
        programming-haskell
        programming
        shell-zsh
        shelltools
        vim
        tmux
        ssh
      ];
    };
}
