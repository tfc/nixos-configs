{ pkgs, ... }:

let
  sessionVariables = {
    EDITOR = "vim";
    FOO = "Bar";
    SSH_AUTH_SOCK = "/run/user/$UID/gnupg/S.gpg-agent.ssh";
  };

in
{
  home.packages = with pkgs; [
    gpa
  ];

  programs.zsh.sessionVariables = {
    SSH_AUTH_SOCK = "~/.gnupg/S.gpg-agent.ssh";
  };

  # the rest down here should not be enabled on macos
  home.sessionVariables = sessionVariables;

  programs.bash.bashrcExtra = ''
    SSH_AUTH_SOCK="/run/user/$UID/gnupg/S.gpg-agent.ssh"
  '';

  services = {
    gnome-keyring = {
      enable = true;
      components = [ "pkcs11" "secrets" ]; # no SSH
    };
    gpg-agent = {
      enable = true;
      defaultCacheTtl = 1800;
      enableSshSupport = true;
    };
  };

  # is ignored by gnome
  systemd.user.sessionVariables = sessionVariables;
}
