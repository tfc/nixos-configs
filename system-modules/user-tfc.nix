{ ... }:

{
  programs.vim.defaultEditor = true;

  users.users.tfc = {
    isNormalUser = true;
    extraGroups = [
      "docker"
      "libvirtd"
      "networkmanager"
      "wheel"
    ];
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCXfQnzmqFQsUPwJm1sQSh2A7HH1YxO6OOOn1r2QR/PqwVIRu1rOzAC5IXPKmaIN770dLIJzQMqQoUr3ih/x+zweEyUqJTP0sIjA8l9lJNj0S6xVZ594ci/C6w9fR9uKRmXIk7r6usaqTF0Jdf02Al0tB0Lv4Aqi2b6VNPLO3LT162ZuRpcqSDIZzmQg+lkd0s1jWnJGdX5s7G959ouvID5xx7g/e31M/p4PJFvdEtmZ0YGTqju+STyOvX56GvQKRlRRYVFwwTyC1KUr0fJ31dM0DjZoIrfbeY+MBO6JXT23x6iU2sywqxmrDrRphu3raLI/Y2PhopO0q7DutAoolgV cardno:000606444835"
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDBOn2J1U52OfEUNXbUDtOFT2vCH9nOJBmSvRFkkkgbl3tiEHwyw2VRsykOTxbMXPjXCCski3CZA1CMeL/g/u3TEyA1797eOs+bgCWCo1QvH7//45v7791oA72XmaUwvmXpf8lZM4d1EkQkGwtv2lPp3yth8p+8P9Hx8S7rMZBZQSjQ7ME3liQVjz8Lu0z3sd+InywnysaYxGrfqkGEEM3/j+RruY85/f8UIxnoPw3ehjbI9cjYyGjtjs+h4RpVt5q2d6hOTMKvXz0HZ2q+KOKbsfgZgeeFReez3lTuVD5FaoLT+21PXTEJK5L8qr9XsWLkmfZGK1iri9h/xXG2+1ST cardno:000609623790"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIManOIJLP/sPj7glqo6R1+6+oJJToiNxtbHOLPPU187y tfc@jongebook-legacy"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIODOm+UWxSpA1f7+CAQkTHy3njziOUHePTH/O9OKATer root@jongepad"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKYPVxEpmma7zyX0uVBFP9X0AWCkUGIG7Zpx8iKJA2+T jacek@galowicz.de"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP5MEOU5rwpkGtzR4p/1BEUj2ekg5KmmR+QGF8qNuQFL tfc@jongebook"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIF0iyQuS7BycsHPZCLpkl0ojyiRn2GCPwNhtFjdnwHZx jacek@galowicz.de"
    ];
  };
}
