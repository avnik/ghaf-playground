{
  inputs = {
    ghaf.url = "github:tiiuae/ghaf";
  };
  outputs = inputs@{ ghaf, ...}: {
    nixosConfigurations = {
      carbon = ghaf.nixosConfigurations.lenovo-x1-carbon-gen11-debug.extendModules {
        modules = [
          ./configuration.nix
        ];
      };
    };
  };
}
