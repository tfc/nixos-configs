{ pkgs, ... }:
{
  services.printing = {
    enable = true;
    drivers = with pkgs; [
      brlaser
      mfcj470dw-cupswrapper
      mfcj6510dw-cupswrapper
      samsung-unified-linux-driver
      splix
    ];
  };
}
