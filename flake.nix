{
  description = "A modern NixOS configuration with flake-parts";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    flake-programs-sqlite = {
      url = "github:wamserma/flake-programs-sqlite";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    ...
  }: let
    system = "x86_64-linux";
    pkgs = import nixpkgs {
      system = "x86_64-linux";
    };
  in {
    # NixOS configurations
    nixosConfigurations = {
      semyenov = nixpkgs.lib.nixosSystem {
        system = system;
        specialArgs = {inherit inputs;};

        modules = [
          ./hosts/semyenov/configuration.nix
          {nixpkgs.overlays = [self.overlays.default self.overlays.unstable-packages];}

          inputs.home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = {inherit inputs;};
            home-manager.backupFileExtension = "backup";
            home-manager.users.semyenov = import ./home/users/semyenov.nix;
          }
        ];
      };
    };

    # Development shell
    devShells.${system}.default = pkgs.mkShell {
      packages = with pkgs; [
        git
        nixpkgs-fmt
        statix
        deadnix
        alejandra
        nixd
        nil # Nix language server
      ];

      shellHook = ''
        # Set up aliases
        alias rebuild="sudo nixos-rebuild switch --flake .#semyenov"
        alias update="nix flake update"
        alias check="nix flake check"

        echo "NixOS Development Shell"
        echo "Available commands:"
        echo "  rebuild - Rebuild and switch NixOS configuration"
        echo "  update  - Update flake inputs"
        echo "  check   - Check flake validity"
      '';
    };

    # Formatter
    formatter.${system} = pkgs.nixpkgs-fmt;

    # Custom packages
    packages.${system} = {
      cursor-appimage = pkgs.callPackage ./packages/cursor-appimage.nix {};
      throne = pkgs.callPackage ./packages/throne.nix {};
    };

    overlays = {
      default = import ./overlays/default.nix;
      unstable-packages = final: prev: {
        unstable = import inputs.nixpkgs-unstable {
          system = prev.system;
          config.allowUnfree = true;
        };
      };
    };
  };
}
