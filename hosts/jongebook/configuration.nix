{ config, pkgs, lib, ... }:

{
  environment.systemPackages = with pkgs; [
    git
    nixos-rebuild
    vim
  ];

  #nix.linux-builder.enable = true;

  security.pam.enableSudoTouchIdAuth = true;

  services.nix-daemon.enable = true;
  nix.package = pkgs.nixVersions.nix_2_18;
  nix.extraOptions = ''
    experimental-features = nix-command flakes auto-allocate-uids
    auto-allocate-uids = true
    bash-prompt-prefix = (nix:$name)\040
    build-users-group = nixbld
  '';
  # removed this: extra-nix-path = nixpkgs=flake:nixpkgs

  nix.nixPath = lib.mkForce [ "nixpkgs=${pkgs.path}" ];

  nixpkgs.config.allowUnfree = true;

  programs.zsh.enable = true; # default shell on catalina

  system.checks.verifyBuildUsers = false;

  users.users.tfc.home = "/Users/tfc";
  nix.settings.trusted-users = [ "tfc" ];

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;
}
