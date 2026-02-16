{ config, lib, ... }:
let
  cfg = config.ghaf-playground;

  insecureHostOptions = {
    StrictHostKeyChecking = "no";
    UserKnownHostsFile = "/dev/null";
    GlobalKnownHostsFile = "/dev/null";
    UpdateHostKeys = "no";
    CheckHostIP = "no";
  };

  vmMatchBlocks = lib.listToAttrs (
    map (
      vmName:
      lib.nameValuePair "${cfg.hostName}-${vmName}" {
        hostname = vmName;
        user = cfg.user;
        proxyJump = cfg.hostName;
        forwardAgent = true;
        extraOptions = insecureHostOptions;
      }
    ) cfg.vmNames
  );
in
{
  options.ghaf-playground = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable Ghaf playground SSH shortcuts.";
    };

    hostName = lib.mkOption {
      type = lib.types.str;
      default = "carbon";
      description = "SSH hostname for netvm entry point.";
    };

    user = lib.mkOption {
      type = lib.types.str;
      default = "ghaf";
      description = "SSH username used for Ghaf hosts and VMs.";
    };

    vmNames = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [
        "ghaf-host"
        "admin-vm"
        "gui-vm"
        "audio-vm"
        "ids-vm"
        "business-vm"
        "comms-vm"
        "chrome-vm"
        "flatpak-vm"
      ];
      description = "VM hostnames for generated aliases in the form <hostName>-<vmName>.";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.ssh = {
      enable = true;

      matchBlocks = {
        "*" = {
          extraOptions = insecureHostOptions;
        };

        "${cfg.hostName}" = {
          hostname = cfg.hostName;
          user = cfg.user;
          forwardAgent = true;
          extraOptions = insecureHostOptions;
        };

        "${cfg.hostName}-host" = {
          hostname = "ghaf-host";
          user = cfg.user;
          proxyJump = cfg.hostName;
          forwardAgent = true;
          extraOptions = insecureHostOptions;
        };
      }
      // vmMatchBlocks;
    };
  };
}
