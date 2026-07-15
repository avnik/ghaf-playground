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

  defaultHostOptions = {
    ForwardAgent = false;
    AddKeysToAgent = "no";
    Compression = false;
    ServerAliveInterval = 0;
    ServerAliveCountMax = 3;
    HashKnownHosts = false;
    UserKnownHostsFile = "~/.ssh/known_hosts";
    ControlMaster = "no";
    ControlPath = "~/.ssh/master-%r@%n:%p";
    ControlPersist = "no";
  };

  vmMatchBlocks = lib.listToAttrs (
    map (
      vmName:
      lib.nameValuePair "${cfg.hostName}-${vmName}" (
        {
        HostName = vmName;
        User = cfg.user;
        ProxyJump = cfg.hostName;
        ForwardAgent = true;
        }
        // insecureHostOptions
      )
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
      enableDefaultConfig = false;

      settings = (
        {
        "*" = defaultHostOptions // insecureHostOptions;

        "${cfg.hostName}" = {
          HostName = cfg.hostName;
          User = cfg.user;
          ForwardAgent = true;
        } // insecureHostOptions;

        "${cfg.hostName}-host" = {
          HostName = "ghaf-host";
          User = cfg.user;
          ProxyJump = cfg.hostName;
          ForwardAgent = true;
        } // insecureHostOptions;

      }
      // vmMatchBlocks
      );
    };
  };
}
