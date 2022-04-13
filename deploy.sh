#!/usr/bin/env bash

set -euxo pipefail

hostname="$1"
addr="$2"

nixos-rebuild switch --flake ".#$hostname" --target-host "$addr" --use-remote-sudo
