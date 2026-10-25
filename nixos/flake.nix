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
  };
}
