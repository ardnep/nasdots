{
  description = "ardnas NixOS configuration";

  inputs.nixpkgs.url =
    "github:NixOS/nixpkgs/26f4107e47e3ad0ffd0db220469ba83b6f6d96e8";

  outputs = { self, nixpkgs }: {
    nixosConfigurations.ardnas = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";

      modules = [
        ./configuration.nix
      ];
    };
  };
}
