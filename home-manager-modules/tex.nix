{ pkgs, ... }:
{
  home.packages = with pkgs; [
    # mostly this stuff is needed by pandoc when creating PDFs
    inkscape
    texlive.combined.scheme-tetex
    gnome3.librsvg
    pandoc
  ];
}
