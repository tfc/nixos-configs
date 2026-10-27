_: prev: {
  streamdeck-toml = prev.callPackage ./streamdeck-toml { };
  transcribe-speakers = prev.callPackage ./transcribe-speakers { };
  transcribe-speakers-turns = prev.callPackage ./transcribe-speakers {
    name = "transcribe-speakers-turns";
    variant = "small.en-tdrz";
  };
}
