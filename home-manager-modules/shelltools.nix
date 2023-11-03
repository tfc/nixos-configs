{ pkgs, config, ... }:

let
  collectOld = pkgs.writeScriptBin "nix-collect-old" ''
    nix-env --delete-generations old
    nix-collect-garbage
    nix-collect-garbage -d
    nix-store --gc --print-dead
    nix-store --optimize
  '';
in
{
  imports = [
    ./tmux.nix
  ];
  home.packages = with pkgs; [
    bottom
    collectOld
    file
    gtop
    killall
    lsof
    magic-wormhole
    mosh
    nix-diff
    nix-output-monitor
    nix-prefetch-github
    nix-top
    pstree
    qemu
    tmate
    unrar
    unzip
    zip
  ];

  programs = {
    autojump = {
      enable = true;
      enableBashIntegration = true;
    };
    bat.enable = true;
    command-not-found.enable = true;
    direnv = {
      enable = true;
      enableBashIntegration = true;
      nix-direnv.enable = true;
    };
    dircolors = {
      enable = true;
      enableBashIntegration = true;
    };
    htop = {
      enable = true;
      settings = {
        color_scheme = 6;
        cpu_count_from_zero = true;
        highlight_base_name = true;
        highlight_megabytes = true;
        highlight_threads = true;
      } // (with config.lib.htop; leftMeters [
        (bar "AllCPUs2")
        (bar "Memory")
        (bar "Swap")
        (bar "Battery")
      ]) // (with config.lib.htop; rightMeters [
        (text "Tasks")
        (text "LoadAverage")
        (text "Uptime")
        (text "CPU")
      ]);
    };
    fzf = {
      enable = true;
      enableBashIntegration = true;
    };
    man.enable = true;
  };
}
