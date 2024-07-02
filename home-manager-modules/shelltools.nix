{ pkgs, config, ... }:

{
  imports = [
    ./tmux.nix
  ];
  home.packages = with pkgs; [
    bottom
    file
    gtop
    killall
    lsof
    mosh
    nix-diff
    nix-output-monitor
    nix-prefetch-github
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
