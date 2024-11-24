{
  nixpkgs.config.allowUnfree = true;

  users.extraGroups.vboxusers.members = [ "tfc" ];

  virtualisation.virtualbox.host = {
    enable = true;
    #enableKvm = true;
  };
}
