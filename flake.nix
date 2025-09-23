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
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    ...
  }: let
    system = "x86_64-linux";
    pkgs = import nixpkgs {
      system = "x86_64-linux";
      config.allowUnfree = true;
    };
  in {
    # NixOS configurations
    nixosConfigurations = {
      nixos = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {inherit inputs;};

        modules = [
          ./hosts/default/hardware-configuration.nix
          ./hosts/default/configuration.nix
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
        nil # Nix language server
      ];

      shellHook = ''
        echo "NixOS Development Shell"
        echo "Available commands:"
        echo "  nixos-rebuild switch --flake .#nixos"
        echo "  nix flake update"
        echo "  nix flake check"
      '';
    };

    # Formatter
    formatter.${system} = pkgs.nixpkgs-fmt;

    # Custom packages
    packages.${system} = {
      cursor-appimage = pkgs.callPackage ./packages/cursor-appimage.nix {};
      yandex-music = pkgs.callPackage ./packages/yandex-music.nix {};
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
