{ lib, ... }:
{
  # Keep nix-daemon builds from making an interactive desktop feel sluggish.
  systemd.services.nix-daemon.serviceConfig = {
    # SCHED_IDLE: build workers only get CPU when no SCHED_OTHER task wants
    # it. This is what keeps a video encoder (or any interactive app) from
    # ever competing with the daemon for cycles. Supersedes Nice, which is
    # ignored under this policy.
    CPUSchedulingPolicy = lib.mkForce "idle";
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

    # Hard ceiling: if a runaway build (CUDA/zluda link steps are the usual
    # suspect) blows past MemoryHigh faster than the kernel can throttle,
    # OOM-kill inside the daemon cgroup rather than dragging the whole
    # machine into swap death. A failed build is recoverable; a frozen
    # recording session is not.
    MemoryMax = "85%";
  };

  # Give each build its own cgroup under the daemon slice. Without this the
  # MemoryHigh/MemoryMax above apply to the *sum* of all parallel workers,
  # so one fat derivation can starve the rest; with it, each derivation is
  # accounted and limited independently.
  nix.settings.use-cgroups = true;
  nix.settings.experimental-features = [ "cgroups" ];

  # Reactive safety net for the case where memory pressure ramps faster
  # than cgroup throttling can react (typical when many builds enter their
  # link/codegen phase at once). Kills the worst offender before the
  # desktop session itself gets swapped out.
  services.earlyoom.enable = true;
}
