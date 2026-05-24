{ pkgs, ... }:

{
  services.ollama = {
    enable = true;
    package = pkgs.ollama-cuda;

    # Tuned for an 8GB GPU that also drives the GNOME desktop (~1GB VRAM gone
    # before Ollama starts). omp sends large agentic prompts, so the default
    # 4096-token context truncates them and breaks the agent loop.
    #
    # llama3.1 (4.7GB weights) + a 16k context: an f16 KV cache would be ~2GB
    # and overflow VRAM. Flash attention + an 8-bit KV cache halves that to
    # ~1GB, which fits with headroom.
    environmentVariables = {
      OLLAMA_CONTEXT_LENGTH = "16384";
      OLLAMA_FLASH_ATTENTION = "1";
      OLLAMA_KV_CACHE_TYPE = "q8_0";
      # Default is 5m. With only one ~5GB model resident at a time on this
      # 8GB GPU, keeping it warm across an interactive agent session avoids
      # the 5-15s reload from disk on every prompt after a short pause.
      OLLAMA_KEEP_ALIVE = "1h";
    };
  };

  services.nextjs-ollama-llm-ui.enable = true;

  # Terminal coding agents, both pointed at the local Ollama instance:
  #  - omp (oh-my-pi): a fork of pi with a batteries-included workflow
  #  - pi (pi-mono): the upstream project omp forked from
  #
  # The llm-agents.nix input is pinned (see flake.nix) to the last revision
  # packaging omp 15.0.0. Newer omp (15.0.1+) requires bun >= 1.3.14, and
  # llm-agents.nix's bun-bin 1.3.14 produces standalone binaries that segfault
  # on this host — so 15.0.0 is the newest version that actually runs. pi is a
  # plain Node (buildNpmPackage) build and is unaffected; it comes from the
  # same pinned revision (pi 0.74.0).
  environment.systemPackages = [
    pkgs.llm-agents.omp
    pkgs.llm-agents.pi
  ];

  # omp reads ~/.omp/agent/models.yml. Declare the local Ollama instance as an
  # OpenAI-compatible provider. ~/.omp itself stays writable for omp's session
  # and auth state; only this one file is managed by Nix.
  #
  # All listed models are 7-9B Q4: they fit an 8GB GPU (weights <=5.5GB) and
  # support tool-calling for omp's agentic loop. gemma4:e4b (9.6GB) does not
  # fit; 24B+ agentic models (Devstral etc.) need a >=16GB GPU.
  #
  # Each model id must match the exact `ollama pull` tag. contextWindow MUST
  # match OLLAMA_CONTEXT_LENGTH above — otherwise omp packs more context than
  # Ollama serves and the prompt is silently truncated.
  #
  # Pull the models once before use:
  #   ollama pull qwen3:8b
  #   ollama pull qwen2.5-coder:7b
  #   ollama pull llama3.1:latest
  home-manager.users.tfc.home.file.".omp/agent/models.yml".text = ''
    providers:
      ollama:
        baseUrl: http://localhost:11434/v1
        auth: none
        api: openai-completions
        models:
          # Most stable tool-calling at this size — best default for omp.
          # "thinking" left off to conserve the 16k context budget.
          - id: "qwen3:8b"
            name: Qwen3 8B
            api: openai-completions
            reasoning: false
            input: [text]
            cost: { input: 0, output: 0, cacheRead: 0, cacheWrite: 0 }
            contextWindow: 16384
            maxTokens: 4096
          # Strongest pure-code quality at 7B; good for focused edits.
          - id: "qwen2.5-coder:7b"
            name: Qwen2.5-Coder 7B
            api: openai-completions
            reasoning: false
            input: [text]
            cost: { input: 0, output: 0, cacheRead: 0, cacheWrite: 0 }
            contextWindow: 16384
            maxTokens: 4096
          # Reliable unspecialized baseline.
          - id: "llama3.1:latest"
            name: Llama 3.1 8B
            api: openai-completions
            reasoning: false
            input: [text]
            cost: { input: 0, output: 0, cacheRead: 0, cacheWrite: 0 }
            contextWindow: 16384
            maxTokens: 4096
  '';

  # pi's equivalent of the above: it reads ~/.pi/agent/models.json (JSON, not
  # YAML). Differences from omp's format: apiKey is mandatory (Ollama ignores
  # the value), and `compat` disables the `developer` role / reasoning_effort
  # field that Ollama's OpenAI-compatible endpoint does not understand.
  home-manager.users.tfc.home.file.".pi/agent/models.json".text = builtins.toJSON {
    providers.ollama = {
      baseUrl = "http://localhost:11434/v1";
      api = "openai-completions";
      apiKey = "ollama";
      compat = {
        supportsDeveloperRole = false;
        supportsReasoningEffort = false;
      };
      models =
        let
          mkModel = id: name: {
            inherit id name;
            reasoning = false;
            input = [ "text" ];
            contextWindow = 16384;
            maxTokens = 4096;
            cost = {
              input = 0;
              output = 0;
              cacheRead = 0;
              cacheWrite = 0;
            };
          };
        in
        [
          (mkModel "qwen3:8b" "Qwen3 8B")
          (mkModel "qwen2.5-coder:7b" "Qwen2.5-Coder 7B")
          (mkModel "llama3.1:latest" "Llama 3.1 8B")
        ];
    };
  };
}
