{ pkgs, ... }:
{
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  boot.extraModprobeConfig = "options kvm-intel nested=Y";

  environment.systemPackages = with pkgs; [
    libvirt
    virt-manager
    gnome-boxes
  ];

  virtualisation.libvirtd = {
    enable = true;
    qemu = {
      package = pkgs.qemu_kvm;
      runAsRoot = true;
      swtpm.enable = true;
      ovmf = {
        enable = true;
        packages = [
          (pkgs.OVMF.override {
            secureBoot = true;
            tpmSupport = true;
          }).fd
        ];
      };
    };
  };
}
