{ config, pkgs, ... }:

{
  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = with pkgs; [
    git
    vim
  ];

  services.yabai = {
    enable = true;
  };

  # Use a custom configuration.nix location.
  # $ darwin-rebuild switch -I darwin-config=$HOME/.config/nixpkgs/darwin/configuration.nix
  # environment.darwinConfig = "$HOME/.config/nixpkgs/darwin/configuration.nix";

  services.nix-daemon.enable = true;
  nix.package = pkgs.nix;
  nix.extraOptions = ''
    experimental-features = nix-command flakes auto-allocate-uids
    auto-allocate-uids = true
    bash-prompt-prefix = (nix:$name)\040
    build-users-group = nixbld
    extra-nix-path = nixpkgs=flake:nixpkgs
  '';


  nixpkgs.config.allowUnfree = true;

  programs.zsh.enable = true;  # default shell on catalina

  system.checks.verifyBuildUsers = false;

  users.users.tfc.home = "/Users/tfc";

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;
}
