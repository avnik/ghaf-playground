## My personal experimental playground for Ghaf.

It adapted to be deployed via `nixos-anywhere`.

Boot from any linux flash, setup dummy root password for ssh to bogus,
and issue follow command on your local nixos machine:

```console
# SSHPASS=bogus nix run github:nix-community/nixos-anywhere -- --flake ".#carbon" --ssh-option UserKnownHostsFile=/dev/null --no-substitute-on-destination --env-password -L --target-host root@carbon --disko-mode disko
```

Basic setup (NVMe disk set, no customization):

From dev shell run following command
```console
$ SSHPASS=bogus nixos-anywhere -- --flake ".#basic" --ssh-option UserKnownHostsFile=/dev/null --no-substitute-on-destination --env-password -L --target-host root@carbon --disko-mode disko
```

## Home Manager module to configure fast access Ghaf Carbon laptop

In your local `flake.nix`:
```nix
  inputs = {
    ghaf-playground = {
      url = "github:avnik/ghaf-playground";
      inputs.gp-gui.follows = "";
    };
  };
```

And in your home definition:
```nix
  imports = [ inputs.ghaf-playground.homeManagerModules.ghaf-playground ];
  ghaf-playground.hostName = "carbon";
```

(I assume that you already forward `inputs` definition to Home Manager)

then after apply your config you will be able `ssh carbon-host`, `ssh carbon-admin-vm` etc.
(It still asks password, unless agent forwarding settings from this repo is applied)
