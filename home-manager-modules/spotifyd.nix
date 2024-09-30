_:
{
  services.spotifyd = {
    enable = true;
    settings = {
      global = {
        username = "jacek.galowicz@gmail.com";
        password_cmd = "cat ~/.config/nixpkgs/private/spotify_pw";
        backend = "pulseaudio";
        device_name = "nixosjongepad";
        device_type = "computer";
      };
    };
  };
}
