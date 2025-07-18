{ pkgs, config, ... }:

{
  hardware.graphics = {
    enable = true;
    extraPackages = [ pkgs.mesa ];
    enable32Bit = true;
  };

  services.pulseaudio.support32Bit = config.services.pulseaudio.enable;

  hardware.steam-hardware.enable = true;

  programs.steam.enable = true;
}
