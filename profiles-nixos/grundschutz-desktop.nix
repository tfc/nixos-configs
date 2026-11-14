# BSI Grundschutz++ (KONF, level normal-SdT) for desktops and laptops, see
# https://github.com/applicative-systems/dos. Host-specific deviations live
# in the host config, as grundschutz.requirements."<id>".exempt with a reason.
{ flakeInputs, self, ... }:

{
  imports = [ "${flakeInputs.grundschutz}/profiles/konf-normal-sdt-desktop.nix" ];

  # KONF.2.5: trace the running system back to its commit
  system.configurationRevision = self.rev or self.dirtyRev or null;

  grundschutz.requirements = {
    "KONF.2.2".restrictKeyTypes = false;

    "KONF.2.4".keepServices = [ "bluetooth" ];

    # Desktops are rebuilt locally from the working tree.
    "KONF.2.5".allowDirty = true;

    # Physikalisch-Technische Bundesanstalt, Germany's legal time source.
    "KONF.4.5".allowedTimeServers = [
      "ptbtime1.ptb.de"
      "ptbtime2.ptb.de"
      "ptbtime3.ptb.de"
    ];

    "KONF.6.4".privilegeEscalation = "run0";

    # Updated by hand with nixos-rebuild from the local checkout; an
    # autoUpgrade from GitHub would overwrite uncommitted local changes.
    # KONF.8.1 is covered by the desktop profile's update notification.
    "KONF.8.2".exempt = "Desktop, updated manually via nixos-rebuild";
  };
}
