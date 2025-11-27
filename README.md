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
