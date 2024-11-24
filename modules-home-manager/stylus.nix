{ pkgs, ... }:

{
  home.packages = with pkgs; [
    alchemy
    drawpile
    write_stylus
  ];
}
