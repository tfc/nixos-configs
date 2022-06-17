{ pkgs, ... }:

{
  home.packages = with pkgs; [
    arion
    cachix
    gh
    gti
    jq
    niv
    nix-diff
    nix-linter
    nixpkgs-fmt
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
    };
    aliases = {
      pushfwl = "push --force-with-lease";
      co = "checkout";
    };
  };

  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;
}
