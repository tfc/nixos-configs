_: prev: {
  streamdeck-toml = prev.callPackage ./streamdeck-toml { };
  obsbot-camera-control = prev.callPackage ./obsbot-camera-control { };
  obsbot-tiny-2-control = prev.callPackage ./obsbot-tiny-2-control { };
  tiny2 = prev.callPackage ./tiny2 { };
  tiny2-setup = prev.callPackage ./tiny2-setup { };
  transcribe-speakers = prev.callPackage ./transcribe-speakers { };
  transcribe-speakers-turns = prev.callPackage ./transcribe-speakers {
    name = "transcribe-speakers-turns";
    variant = "small.en-tdrz";
  };
}
