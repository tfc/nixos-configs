{
  # The obsbot-tiny-2-control tool talks to the camera over raw USB via libusb.
  # By default /dev/bus/usb nodes are root-only, so the tool fails with
  # LIBUSB_ERROR_ACCESS unless run as root. This rule tags the OBSBOT Tiny 2
  # (idVendor 3564, idProduct fef8) with "uaccess", which makes systemd-logind
  # grant the user on the active seat read/write access to the device node.
  services.udev.extraRules = ''
    SUBSYSTEM=="usb", ATTRS{idVendor}=="3564", ATTRS{idProduct}=="fef8", TAG+="uaccess"

    # Disable USB runtime autosuspend for the camera. After idling suspended
    # for a while, the firmware stops answering stream setup
    # ("Failed to set UVC probe control : -110"), so meetings get no video
    # until the camera is replugged.
    ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="3564", ATTR{idProduct}=="fef8", ATTR{power/control}="on"
  '';
}
