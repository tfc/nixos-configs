{ lib, pkgs, config, ... }:

let
  llama-cpp = pkgs.llama-cpp.override { rocmSupport = true; };
  llama-server = lib.getExe' llama-cpp "llama-server";
in
{
  hardware.graphics.enable = true;
  hardware.amdgpu.zluda.enable = true;

  programs.nix-required-mounts = {
    enable = true;
    presets.zluda.enable = true;
  };

#  services.ollama = {
#    enable = true;
#    package = pkgs.ollama-rocm;
#  };
#  services.nextjs-ollama-llm-ui.enable = true;

  environment.systemPackages = [
    pkgs.llama-cpp
    pkgs.amdgpu_top
  ];

  services.llama-swap = {
    enable = true;
    port = 8012;
    settings = {
      # Increase health check timeout to 1 hour to accommodate large model downloads
      healthCheckTimeout = 3600;
      logToStdout = "both";
      # All models in here have to be in GGUF format.
      # Browse https://huggingface.co/unsloth to find more GGUF models.
      models = {
        "gemma4:e2b" = {
          cmd = "${llama-server} -hf unsloth/gemma-4-E2B-it-GGUF:IQ4_XS --port \${PORT}";
        };
        "qwen3.5:0.8b" = {
          cmd = "${llama-server} -hf unsloth/Qwen3.5-0.8B-GGUF --port \${PORT}";
        };
        "qwen3.5:27b" = {
          cmd = "${llama-server} -hf unsloth/Qwen3.5-27B-GGUF --port \${PORT}";
        };
        "qwen3.5:35b" = {
          cmd = "${llama-server} -hf unsloth/Qwen3.5-35B-A3B-GGUF --port \${PORT}";
        };
        "qwen3.5:122b" = {
          cmd = "${llama-server} -hf unsloth/Qwen3.5-122B-A10B-GGUF:UD-Q3_K_XL --port \${PORT}";
        };
      };
    };
  };

  # fix llama-cpp not able to create cache directory
  systemd.services.llama-swap = {
    environment.XDG_CACHE_HOME = "/var/cache/llama.cpp";
    serviceConfig.CacheDirectory = "llama.cpp";
  };
}
