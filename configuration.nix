{ lib, config, pkgs, inputs, ... }:
{
  # Help disko/nixos-anywhere to find/destroy disk
  disko.devices.disk.disk1.device = "/dev/nvme0n1";
  ghaf.partitioning.disko.enable = true;
  ghaf.storage.encryption.enable = lib.mkForce true;
  ghaf.reference.profiles.mvp-user-trial.enable = lib.mkForce true;

  # Disable plymouth, I need to see how device boot and all error messages 
  ghaf.graphics.boot.enable = lib.mkForce false;
  ghaf.profiles.release.enable = lib.mkForce false;
  ghaf.profiles.debug.enable = lib.mkForce true;

  ghaf.reference.personalize.keys = {
    enable = true;
    authorizedSshKeys = ["ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC/Oz6zPS9Ir/+2L296MBtLU45ayJNtEAla2HVpl+DUhNe9b9TTwLf25hbgp9rzwF6p7hj3HT8cJGpK44AOASWLnJOvg7YzrxwfvaLQjhNECIsJrxOuulQbmtmVeAh2no96ze3hus6xfoj3TaLH4sbgf181TCgbdu/GsGLckrFGRjvS69mNjzEiQBg09fjhnU8gPESirSdjIfF15ro4jXNlnTSKenqrdbZ7TkwgaQWO2MixXC6YCaMUpaJDqUPRW1N3WVdc3+cuO81XhkinwXpN27XHA6TJWPy5oJha0zlg2z3RhNIzxAy2J6kD7yViypcaMRSoK7Xoi9EYQkGd9uIT avn@bulldozer"];
  };
  users.users.ghaf.openssh.authorizedKeys.keys = config.ghaf.reference.personalize.keys.authorizedSshKeys;
  ghaf.hardware.definition.netvm = {
    extraModules = [
      ({...}: {
        users.users.ghaf.openssh.authorizedKeys.keys = config.ghaf.reference.personalize.keys.authorizedSshKeys;

        services.openssh.settings.AllowAgentForwarding = "yes";

        programs.ssh.extraConfig = ''
          Host *
            ForwardAgent yes
        '';
      })
    ];
  };
}
