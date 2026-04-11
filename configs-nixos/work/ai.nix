{ pkgs, ... }:

{
  services.ollama = {
    enable = true;
    package = pkgs.ollama-cuda;
  };

  services.nextjs-ollama-llm-ui.enable = true;
}
