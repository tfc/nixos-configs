_:

{
  virtualisation.docker.rootless = {
    enable = true;
    setSocketVariable = true;
    daemon.settings = {
      registry-mirrors = [
        "http://192.168.1.239:5001"
        "https://mirror.gcr.io"
      ];
      insecure-registries = [ "192.168.1.239:5001" ];
    };
  };
}
