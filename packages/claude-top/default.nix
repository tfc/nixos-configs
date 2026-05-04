{ writers }:

writers.writePython3Bin "claude-top" {
  flakeIgnore = [
    "E501" # line too long
    "W503" # line break before binary operator
  ];
} (builtins.readFile ./claude_top.py)
