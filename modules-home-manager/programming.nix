{ pkgs, ... }:

{
  home.packages = with pkgs; [
    cachix
    claude-top
    claude-top-sound
    deadnix
    gh
    gti
    httpie
    jq
    loccount
    niv
    nix-diff
    nixfmt
    nixpkgs-fmt
    play-ready-sound
    shellcheck
    socat
    statix
    vhs
    yq
  ] ++ (lib.optionals pkgs.stdenv.isLinux [
    iotop
  ]);

  programs.git = {
    enable = true;
    lfs.enable = true;
    settings = {
      credential.helper = "store";
      init.defaultBranch = "main";
      push.autoSetupRemote = true;
      user = {
        name = "Jacek Galowicz";
        email = "jacek@applicative.systems";
      };
      alias = {
        pushfwl = "push --force-with-lease";
        co = "checkout";
        cp = "cherry-pick";
      };
    };
    signing.format = null;
  };

  programs.lazygit.enable = true;

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    config.global.hide_env_diff = true;
  };
}
