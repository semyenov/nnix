{
  description = "A modern NixOS configuration with flake-parts";

  inputs = {
    # Core NixOS
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    # Home Manager
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Hardware support
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    # Development tools
    flake-programs-sqlite = {
      url = "github:wamserma/flake-programs-sqlite";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Additional useful flakes
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    # Development environments
    devshell = {
      url = "github:numtide/devshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Nix development tools
    nixd = {
      url = "github:nix-community/nixd";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Pre-commit hooks
    pre-commit-hooks = {
      url = "github:cachix/pre-commit-hooks.nix";
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

    # Home Manager configurations
    homeConfigurations = {
      semyenov = inputs.home-manager.lib.homeManagerConfiguration {
        pkgs = import inputs.nixpkgs {
          system = system;
          overlays = [self.overlays.default self.overlays.unstable-packages];
        };
        extraSpecialArgs = {inherit inputs;};
        modules = [./home/users/semyenov.nix];
      };
    };

    # Enhanced development shell
    devShells.${system}.default = pkgs.mkShell {
      packages = with pkgs; [
        # Core Nix tools
        git
        nixpkgs-fmt
        statix
        deadnix
        alejandra
        nixd
        nil # Nix language server
        nix-tree
        nix-du
        nix-output-monitor

        # Development utilities
        direnv
        zoxide
        fzf
        ripgrep
        fd
        bat
        eza
        procs
        dust
        duf
        bottom
        dog

        # System monitoring
        htop
        iotop
        nethogs
        iftop

        # Network tools
        curl
        wget
        httpie
        jq
        yq-go

        # Text processing
        sd
        tealdeer
        hyperfine
        tokei

        # Version control
        gh
        glab
        lazygit

        # Container tools
        docker
        docker-compose
        podman

        # Security tools
        age
        sops
        gnupg

        # Documentation
        pandoc
        texlive.combined.scheme-full

        # Fun utilities
        neofetch
        onefetch
        figlet
        cowsay
        lolcat
      ];

      shellHook = ''
        # Enhanced shell hook
        echo "🚀 NixOS Development Shell"
        echo "=========================="
        echo "Available commands:"
        echo "  rebuild     - Rebuild and switch NixOS configuration"
        echo "  update      - Update flake inputs"
        echo "  check       - Check flake validity"
        echo "  clean       - Clean Nix store"
        echo "  generations - Show system generations"
        echo ""
        echo "Development tools:"
        echo "  nix-tree    - Visualize dependency tree"
        echo "  nix-du      - Analyze disk usage"
        echo "  statix      - Lint Nix code"
        echo "  deadnix     - Find unused code"
        echo "  alejandra   - Format Nix code"
        echo ""

        # Set up environment
        export NIX_CONFIG="experimental-features = nix-command flakes"

        # Enhanced aliases
        alias rebuild="sudo nixos-rebuild switch --flake .#semyenov"
        alias update="nix flake update"
        alias check="nix flake check"
        alias clean="sudo nix-collect-garbage -d"
        alias generations="sudo nix-env --list-generations --profile /nix/var/nix/profiles/system"
        alias nix-tree="nix-tree"
        alias nix-du="nix-du"
        alias format="alejandra ."
        alias lint="statix ."
        alias unused="deadnix ."

        # Fun startup
        if command -v neofetch >/dev/null 2>&1; then
          neofetch --ascii_distro nixos
        fi
      '';
    };

    # Formatter
    formatter.${system} = pkgs.nixpkgs-fmt;

    # Custom packages
    packages.${system} = {
      cursor-appimage = pkgs.callPackage ./packages/cursor-appimage.nix {};
      throne = pkgs.callPackage ./packages/throne.nix {};
    };

    # Additional useful outputs
    apps.${system} = {
      rebuild = {
        type = "app";
        program = "${pkgs.writeShellScript "rebuild" ''
          sudo nixos-rebuild switch --flake .#semyenov
        ''}";
      };
      update = {
        type = "app";
        program = "${pkgs.writeShellScript "update" ''
          nix flake update
        ''}";
      };
      clean = {
        type = "app";
        program = "${pkgs.writeShellScript "clean" ''
          sudo nix-collect-garbage -d
        ''}";
      };
    };

    # Checks
    checks.${system} = {
      nixos-config = pkgs.lib.nixosSystem {
        system = system;
        specialArgs = {inherit inputs;};
        modules = [
          ./hosts/semyenov/configuration.nix
          {nixpkgs.overlays = [self.overlays.default self.overlays.unstable-packages];}
        ];
      };
    };

    # Templates
    templates = {
      nixos = {
        path = ./templates/nixos;
        description = "A basic NixOS configuration";
      };
      home-manager = {
        path = ./templates/home-manager;
        description = "A basic Home Manager configuration";
      };
    };

    # Overlays
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
