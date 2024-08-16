{ pkgs, config, ... }: {
  hardware.opengl = {
    # this fixes the "glXChooseVisual failed" bug,
    # context: https://github.com/NixOS/nixpkgs/issues/47932
    enable = true;
    driSupport32Bit = true;
  };
  hardware.opengl.extraPackages = [ pkgs.mesa.drivers ];

  # optionally enable 32bit pulseaudio support if pulseaudio is enabled
  hardware.pulseaudio.support32Bit = config.hardware.pulseaudio.enable;

  hardware.steam-hardware.enable = true;

  programs.steam.enable = true;
}
