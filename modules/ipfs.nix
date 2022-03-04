{ ... }:
{
  services.ipfs = {
    enable = true;
    autoMount = true;
    enableGC = true;
    extraConfig = {
      Swarm.EnableAutoRelay = true; # because router network
    };
  };
}
