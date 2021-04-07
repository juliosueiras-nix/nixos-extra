{
  description = "A very basic flake";

  inputs.nixpkgs.url = "github:nixos/nixpkgs/1ac507ba981970c8e864624542e31eb1f4049751";

  outputs = { self, nixpkgs }: let
    pkgs = import nixpkgs {
      system = "x86_64-linux";
      config = {
        allowUnfree = true;
      };
    };
  in {
    packages.x86_64-linux = pkgs.callPackage ./pkgs/top-level.nix {};

    nixosModules = import ./modules/top-level.nix self;

    devShell.x86_64-linux = pkgs.mkShell {
      NIX_PATH = "nixpkgs=${nixpkgs}";

      buildInputs = [
        pkgs.arion
      ];
    };
  };
}
