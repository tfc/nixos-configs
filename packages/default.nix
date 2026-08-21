_: prev: {
  play-ready-sound = prev.callPackage ./play-ready-sound { };
  claude-top = prev.callPackage ./claude-top { };
  claude-top-sound = prev.callPackage ./claude-top-sound { };
  obsbot-camera-control = prev.callPackage ./obsbot-camera-control { };
  obsbot-tiny-2-control = prev.callPackage ./obsbot-tiny-2-control { };
  tiny2 = prev.callPackage ./tiny2 { };
  transcribe-speakers = prev.callPackage ./transcribe-speakers { };
  transcribe-speakers-turns = prev.callPackage ./transcribe-speakers {
    name = "transcribe-speakers-turns";
    variant = "small.en-tdrz";
  };
}
