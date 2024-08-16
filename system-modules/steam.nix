{ pkgs, config, ... }: {
  hardware.graphics = {
    enable = true;
    extraPackages = [ pkgs.mesa.drivers ];
    enable32Bit = true;
  };

  # optionally enable 32bit pulseaudio support if pulseaudio is enabled
  hardware.pulseaudio.support32Bit = config.hardware.pulseaudio.enable;

  hardware.steam-hardware.enable = true;

  programs.steam.enable = true;
}
