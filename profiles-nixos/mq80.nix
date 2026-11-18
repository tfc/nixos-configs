{ pkgs, ... }:

{
  environment.systemPackages = [ pkgs.kbd-glow ];

  # Let the seat user talk VIA to the IQUNIX MQ80 (kbd-glow) without root.
  # Only interface 1 (the VIA raw-HID endpoint), not the keystroke interfaces.
  # Shipped as a 70-*.rules file: uaccess tags must be set before
  # 73-seat-late.rules, so services.udev.extraRules (99-local.rules) is too late.
  services.udev.packages = [
    (pkgs.writeTextFile {
      name = "mq80-udev-rules";
      destination = "/etc/udev/rules.d/70-mq80.rules";
      text = ''
        SUBSYSTEM=="hidraw", ENV{ID_VENDOR_ID}=="320f", ENV{ID_MODEL_ID}=="5055", ENV{ID_USB_INTERFACE_NUM}=="01", TAG+="uaccess"
      '';
    })
  ];
}
