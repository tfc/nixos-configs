_:
{
  nix.buildMachines =
    let
      default = {
        system = "x86_64-linux";
        protocol = "ssh-ng";
        maxJobs = 4;
        speedFactor = 2;
        supportedFeatures = [ "benchmark" "big-parallel" ];
        mandatoryFeatures = [ ];
      };
    in
    [
      (default // {
        hostName = "build01.nix-consulting.de";
        maxJobs = 4;
        speedFactor = 2;
      })
    ];

  nix.distributedBuilds = true;
  nix.extraOptions = ''
    builders-use-substitutes = true
  '';
}
