{
  inputs = {
    ghaf.url = "github:tiiuae/ghaf";
    flake-parts.follows = "ghaf/flake-parts";
    nixpkgs.follows = "ghaf/nixpkgs"; # Parts require nixpkgs input
    devshell.follows = "ghaf/devshell";
    nixos-anywhere = {
      url = "github:nix-community/nixos-anywhere";

      # Bind to our nixpkgs and disko, stub unused stuff
      inputs.disko.follows = "ghaf/disko";
      inputs.nixpkgs.follows = "ghaf/nixpkgs";
      inputs.nixos-stable.follows = "ghaf/nixpkgs";
      inputs.nix-vm-test.follows = "";
      inputs.treefmt-nix.follows = "";
    };
  };
  outputs =
    inputs@{ self, ghaf, ... }:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" ];
      imports = [ inputs.devshell.flakeModule ];
      flake.nixosConfigurations = {
        # Bare ghaf for lenovo X1 carbon gen11
        basic = ghaf.nixosConfigurations.lenovo-x1-carbon-gen11-debug.extendModules {
          modules = [
            ./basic.nix
          ];
        };
        carbon = ghaf.nixosConfigurations.lenovo-x1-carbon-gen11-debug.extendModules {
          modules = [
            ./configuration.nix
          ];
        };
      };
      flake.homeManagerModules = {
        ghaf-playground = ./home/ghaf-playground.nix;
      };
      perSystem =
        { system, ... }:
        {
          packages = {
            carbon-sysupdate = (self.nixosConfigurations.carbon.extendModules {
              modules = [
                ({
                  ghaf.partitioning.verity-volume.enable = true;
                })
              ];
            }).config.system.build.ghafImage;
          };
          devshells.default = {
            devshell = {
              name = "ghaf-playground";
              motd = ''
                $(type -p menu &>/dev/null && menu)
              '';
            };
            packages = [
              inputs.nixos-anywhere.packages.${system}.nixos-anywhere
            ];
          };
        };
    };
}
