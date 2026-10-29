{
  description = "ardnas NixOS configuration";

  inputs.nixpkgs.url =
    "github:NixOS/nixpkgs/nixos-26.05";

  inputs.disko = {
    url = "git+https://github.com/nix-community/disko.git?ref=refs/tags/latest";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, disko }: {
    nixosConfigurations.ardnas = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";

      modules = [
        ./configuration.nix
        disko.nixosModules.disko
      ];
    };

    packages.x86_64-linux.ugreen-leds =
      self.nixosConfigurations.ardnas.config.boot.kernelPackages.callPackage
      ./ugreen-leds/package.nix
      { };

    packages.x86_64-linux.ugreen-leds-activity =
      nixpkgs.legacyPackages.x86_64-linux.callPackage
      ./ugreen-leds/activity-package.nix
      { };
  };
}
