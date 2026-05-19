{ lib, ... }:
{
  # Keep nix-daemon builds from making an interactive desktop feel sluggish.
  systemd.services.nix-daemon.serviceConfig = {
    # Process-level priority. Inherited by every build worker.
    Nice = lib.mkForce 15;
    IOSchedulingClass = lib.mkForce "idle";
    IOSchedulingPriority = lib.mkForce 7;

    # cgroup-v2 weights apply to the whole nix-daemon service slice, so all
    # build workers contend as a single group against the interactive
    # session (which keeps the default weight of 100). This is what actually
    # keeps the desktop snappy under a saturating `make -jN`; `Nice` alone
    # only arbitrates process-vs-process.
    CPUWeight = 20;
    IOWeight = 20;

    # Soft memory cap: under pressure the kernel reclaims pages from the
    # daemon's cgroup before swapping out the desktop session. Not a hard
    # limit, so builds are throttled rather than OOM-killed.
    MemoryHigh = "70%";
  };
}
