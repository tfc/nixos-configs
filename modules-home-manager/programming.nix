{ pkgs, ... }:

{
  home.packages = with pkgs; [
    cachix
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
    shellcheck
    statix
    yq
  ];

  programs.git = {
    enable = true;
    userName = "Jacek Galowicz";
    userEmail = "jacek@galowicz.de";
    lfs.enable = true;
    extraConfig = {
      credential.helper = "store";
      init.defaultBranch = "main";
      push.autoSetupRemote = true;
    };
    aliases = {
      pushfwl = "push --force-with-lease";
      co = "checkout";
      cp = "cherry-pick";
    };
  };

  programs.lazygit.enable = true;

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    config.global.hide_env_diff = true;
  };
}
