# Set the OBSBOT Tiny 2 AI tracking mode through the uvcvideo driver.
# Unlike obsbot-tiny-2-control (libusb), this doesn't reset the USB device,
# so running video streams (OBS) keep going.
import ctypes
import fcntl
import struct
import sys

DEV = "/dev/v4l/by-id/usb-Remo_Tech_Co.__Ltd._OBSBOT_Tiny_2-video-index0"
UVCIOC_CTRL_QUERY = 0xC0107521  # _IOWR('u', 0x21, struct uvc_xu_control_query)
UVC_SET_CUR = 0x01
XU_UNIT, XU_SELECTOR, XU_LEN = 2, 6, 60

MODES = {
    "stop": b"\x00\x00",
    "normal": b"\x02\x00",
    "upperbody": b"\x02\x01",
    "closeup": b"\x02\x02",
    "headless": b"\x02\x03",
    "lowerbody": b"\x02\x04",
    "group": b"\x01\x00",
    "hand": b"\x03\x00",
    "whiteboard": b"\x04\x00",
}

data = (b"\x16\x02" + MODES[sys.argv[1]]).ljust(XU_LEN, b"\x00")
buf = ctypes.create_string_buffer(data, XU_LEN)
query = struct.pack("BBBxHxxQ", XU_UNIT, XU_SELECTOR, UVC_SET_CUR, XU_LEN, ctypes.addressof(buf))
with open(DEV, "rb+", buffering=0) as f:
    fcntl.ioctl(f.fileno(), UVCIOC_CTRL_QUERY, query)
