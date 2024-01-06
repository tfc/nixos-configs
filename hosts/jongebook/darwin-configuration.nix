{ config, pkgs, lib, ... }:

{
  environment.systemPackages = with pkgs; [
    git
    nixos-rebuild
    utm
    vim
  ];

  nix.linux-builder = {
    enable = true;
    maxJobs = 4;
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
  };

  system.stateVersion = 4;
}
