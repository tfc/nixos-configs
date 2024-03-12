{ pkgs, ... }:

{
  home.packages = with pkgs; [
    arion
    cachix
    gh
    gti
    httpie
    jq
    niv
    nix-diff
    nixpkgs-fmt
    pgcli
    shellcheck
    sloccount
    yq
  ];

  programs.git = {
    enable = true;
    userName = "Jacek Galowicz";
    userEmail = "jacek@galowicz.de";
    lfs.enable = true;
    delta.enable = true;
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

  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;
}
