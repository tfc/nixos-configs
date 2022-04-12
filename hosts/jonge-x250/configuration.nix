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

  system.autoUpgrade = {
    enable = true;
    flake = "github:tfc/nixos-configs";
    allowReboot = true;
    flags = [
      " --no-write-lock-file"
    ];
  };

  users.users.tfc = {
    isNormalUser = true;
    extraGroups = [ "wheel" "libvirtd" ];
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCXfQnzmqFQsUPwJm1sQSh2A7HH1YxO6OOOn1r2QR/PqwVIRu1rOzAC5IXPKmaIN770dLIJzQMqQoUr3ih/x+zweEyUqJTP0sIjA8l9lJNj0S6xVZ594ci/C6w9fR9uKRmXIk7r6usaqTF0Jdf02Al0tB0Lv4Aqi2b6VNPLO3LT162ZuRpcqSDIZzmQg+lkd0s1jWnJGdX5s7G959ouvID5xx7g/e31M/p4PJFvdEtmZ0YGTqju+STyOvX56GvQKRlRRYVFwwTyC1KUr0fJ31dM0DjZoIrfbeY+MBO6JXT23x6iU2sywqxmrDrRphu3raLI/Y2PhopO0q7DutAoolgV cardno:000606444835"
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDBOn2J1U52OfEUNXbUDtOFT2vCH9nOJBmSvRFkkkgbl3tiEHwyw2VRsykOTxbMXPjXCCski3CZA1CMeL/g/u3TEyA1797eOs+bgCWCo1QvH7//45v7791oA72XmaUwvmXpf8lZM4d1EkQkGwtv2lPp3yth8p+8P9Hx8S7rMZBZQSjQ7ME3liQVjz8Lu0z3sd+InywnysaYxGrfqkGEEM3/j+RruY85/f8UIxnoPw3ehjbI9cjYyGjtjs+h4RpVt5q2d6hOTMKvXz0HZ2q+KOKbsfgZgeeFReez3lTuVD5FaoLT+21PXTEJK5L8qr9XsWLkmfZGK1iri9h/xXG2+1ST cardno:000609623790"
    ];
  };
}
