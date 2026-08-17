{
  pkgs,
  lib,
  flakeInputs,
  self,
  ...
}:

let
  hostName = "jongebook";
in
{
  nixpkgs.hostPlatform = "aarch64-darwin";

  nixpkgs.overlays = [
    self.overlays.default
    flakeInputs.traynix.overlays.default
    flakeInputs.traynix.overlays.naersk
  ];

  system.primaryUser = "tfc";

  imports = [
    flakeInputs.home-manager.darwinModules.home-manager
    flakeInputs.traynix.darwinModules.default
  ];

  environment.systemPackages = with pkgs; [
    git
    nixos-rebuild
    utm
    vim
  ];

  services.traynix.enable = true;

  nix.linux-builder = {
    package = pkgs.darwin.linux-builder-vz;
    systems = [
      "aarch64-linux"
      "x86_64-linux"
    ];

    enable = true;
    ephemeral = true;
    maxJobs = 4;
    supportedFeatures = [
      "kvm"
      "benchmark"
      "big-parallel"
      "nixos-test"
      "uid-range" # Needed by nixos tests with containers
    ];
    config = {
      virtualisation = {
        darwin-builder = {
          diskSize = 80 * 1024;
          memorySize = 24 * 1024;
        };
        cores = 2;
        vz.nestedVirtualization = true;
      };

      boot.kernel.sysctl."kernel.panic_on_oops" = 1;

      boot.kernel.sysctl."vm.panic_on_oom" = 1;
      boot.kernelParams = [ "panic=10" ];

      # "/" is a tmpfs (see nixos/modules/virtualisation/vz-vm.nix).
      # Builds default to temp which is a limited tmpfs.
      # Put builds on disk to enable the larger ones.
      systemd.tmpfiles.settings."10-nix-build-dir"."/nix/.rw-store/build".d = {
        user = "root";
        group = "root";
        mode = "0755";
      };

      nix.settings = {
        build-dir = "/nix/.rw-store/build";

        # needed for nixos tests with containers
        system-features = [ "uid-range" ];
        experimental-features = [
          "auto-allocate-uids"
          "cgroups"
        ];
        auto-allocate-uids = true;
        use-cgroups = true;
      };
    };
  };

  nix = {
    # Run `softwareupdate --install-rosetta --agree-to-license` first
    extraOptions = ''
      extra-platforms = x86_64-darwin aarch64-darwin
    '';
    settings = {
      # This sometimes leads to https://github.com/NixOS/nix/issues/7273
      # auto-optimise-store = true;
      experimental-features = [
        "flakes"
        "nix-command"
        "blake3-hashes"
      ];
      system-features = [
        "big-parallel"
        "nixos-test"
        "apple-virt"
      ];
      #sandbox = true; # breaks many builds
      trusted-users = [ "@admin" ];
    };
    nixPath = lib.mkForce [ "nixpkgs=${pkgs.path}" ];
    #package = pkgs.nixVersions.latest;
  };

  nixpkgs.config.allowUnfree = true;

  security.pam.services.sudo_local.touchIdAuth = true;
  programs.bash.completion.enable = true;

  programs.zsh = {
    enable = true;
    enableBashCompletion = true;
    enableFzfCompletion = true;
    enableFzfGit = true;
    enableFzfHistory = true;
  };

  environment.variables.LANG = "en_US.UTF-8";

  users.users.tfc.home = "/Users/tfc";

  fonts.packages = with pkgs; [
    powerline-fonts
  ];

  system.defaults = {
    dock.autohide = true;
    finder.AppleShowAllExtensions = true;
    finder.FXPreferredViewStyle = "clmv";
    loginwindow.LoginwindowText = "nixcademy.com";
    screencapture.location = "~/Pictures/screenshots";
    screensaver.askForPasswordDelay = 10;
  };

  system.defaults.smb.NetBIOSName = hostName;
  networking.hostName = hostName;
  networking.localHostName = hostName;

  system.stateVersion = 4;

  home-manager.useGlobalPkgs = true;
  home-manager.backupFileExtension = "backup";
  home-manager.users.tfc =
    { ... }:
    {
      home.stateVersion = "23.11";
      programs.home-manager.enable = true;
      imports = with self.homeManagerModules; [
        programming
        programming-haskell
        shell-zsh
        shelltools
        ssh
        tmux
        vim
      ];
    };
}
