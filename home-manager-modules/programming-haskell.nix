{ pkgs, ... }:

{
  imports = [ ./programming.nix ];

  home.packages = with pkgs; [
    hlint
  ];

  home.file = {
    ".ghci".text = ''
      :set prompt "λ> "
    '';
  };
}
