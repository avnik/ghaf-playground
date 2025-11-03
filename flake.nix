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
  outputs = inputs@{ ghaf, ...}: 
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux"];
      imports = [ inputs.devshell.flakeModule ];
      flake.nixosConfigurations = {
        # By unknown reasons, extendModules didn't works well with ghaf
        notworks = ghaf.nixosConfigurations.lenovo-x1-carbon-gen11-debug.extendModules {
          modules = [
            ./configuration.nix
          ];
        };
        carbon =
          let
            mkLaptopConfiguration = inputs.ghaf.builders.mkLaptopConfiguration {
              self = inputs.ghaf;
              inherit inputs;
              inherit (inputs.ghaf) lib;
              system = "x86_64-linux";
            };
            laptop-configuration =  mkLaptopConfiguration "lenovo-x1-carbon-gen11" "debug" (
              [ 
                ./configuration.nix
                inputs.ghaf.nixosModules.disko-debug-partition
                inputs.ghaf.nixosModules.hardware-lenovo-x1-carbon-gen11
                inputs.ghaf.nixosModules.reference-profiles
                inputs.ghaf.nixosModules.profiles
              ]
            );
          in laptop-configuration.hostConfiguration;
      };
      perSystem = { system, ... }: {
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
