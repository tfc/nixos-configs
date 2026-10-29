{
  writeShellApplication,
  obsbot-tiny-2-control,
  v4l-utils,
}:

writeShellApplication {
  name = "tiny2-setup";
  runtimeInputs = [
    obsbot-tiny-2-control
    v4l-utils
  ];
  text = ''
    dev=/dev/v4l/by-id/usb-Remo_Tech_Co.__Ltd._OBSBOT_Tiny_2-video-index0

    # Toggle tracking off and on; it often doesn't start properly with a single set.
    obsbot-tiny-2-control -ai stop -ai upperbody

    # The Python tool resets the USB device, so set white balance afterwards.
    udevadm settle
    v4l2-ctl -d "$dev" -c white_balance_automatic=0 -c white_balance_temperature=5500
  '';
}
