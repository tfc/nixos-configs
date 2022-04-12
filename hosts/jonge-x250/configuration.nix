{ pkgs, ... }: {
  boot.cleanTmpDir = true;

  boot.loader.grub.enable = true;
  boot.loader.grub.efiSupport = true;
  boot.loader.grub.device = "nodev";
  boot.loader.grub.configurationLimit = 3;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;

  console.keyMap = "us";

  environment.systemPackages = with pkgs; [ git vim wget ];

  i18n.defaultLocale = "en_US.UTF-8";

  networking.hostName = "jonge-x250";
  networking.firewall.logRefusedConnections = false;
  networking.wireless = {
    enable = true;
    interfaces = [ "wlp3s0" ];
    networks = {
      "Trafo Hub Member".psk = "@PASS_TRAFO@";
      "jongenet".psk = "@PASS_JONGENET@";
    };
    environmentFile = "/var/secrets/wireless.env";
    userControlled.enable = true;
  };

  nix.optimise.automatic = true;
  nix.gc = {
    automatic = true;
    options = "--max-freed 40G";
  };

  nixpkgs.config.allowUnfree = true;
  time.timeZone = "Europe/Berlin";

  services.openssh.enable = true;
  services.hercules-ci-agent.enable = true;

  system.stateVersion = "20.03";
}
