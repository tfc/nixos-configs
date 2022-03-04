
# Local deployment of a config

```sh
nixos-rebuild switch --flake .#<config-name>
```

or

```sh
nix build .#nixosConfigurations.<config-name>.config.system.build.toplevel
sudo ./result/bin/switch-to-configuration switch
```

# Remote deployment of a config

```sh
nixos-rebuild switch --flake .#<config-name> --target-host <hostname> --use-remote-sudo
```
