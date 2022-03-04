{ config, pkgs, ... }:

{
  environment.shellInit = ''
    export GPG_TTY="$(tty)"
    gpg-connect-agent /bye
    export SSH_AUTH_SOCK="/run/user/$UID/gnupg/S.gpg-agent.ssh"
  '';

  environment.systemPackages = with pkgs; [
    gnupg
    paperkey
    pinentry
    pinentry-curses
  ];

  programs = {
    ssh.startAgent = false;
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
      #pinentryFlavor = "curses";
    };
  };

  services = {
    pcscd.enable = true;
    udev = {
      packages = with pkgs; [
        libu2f-host
        yubikey-personalization
      ];
    };
  };
}
