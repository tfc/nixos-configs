{ pkgs, ... }:
{
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  boot.extraModprobeConfig = "options kvm-intel nested=Y";

  environment.systemPackages = with pkgs; [
    arion
    docker-client # arion uses this to talk to podman
    libvirt
    virt-manager
    gnome.gnome-boxes
  ];

  virtualisation.docker.enable = false;
  virtualisation.podman.enable = true;
  virtualisation.podman.dockerSocket.enable = true;
  virtualisation.podman.defaultNetwork.dnsname.enable = true;
  users.extraUsers.tfc.extraGroups = [ "podman" ];

  virtualisation.libvirtd.enable = true;
}
