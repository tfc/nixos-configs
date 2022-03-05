
# Local deployment of a config

```sh
# flake system attribute is automatically selected from current hostname
nixos-rebuild switch --flake github:tfc/nixos-configs
```

or

```sh
nix build github:tfc/nixos-configs#nixosConfigurations.<config-name>.config.system.build.toplevel
sudo nix-env -p /nix/var/nix/profiles/system --set $(readlink result)
sudo ./result/bin/switch-to-configuration switch
```

# Remote deployment of a config

```sh
nixos-rebuild switch --flake github:tfc/nixos-configs#<config-name> --target-host <hostname> --use-remote-sudo
```
