# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Type

This is a **NixOS configuration repository** using Nix Flakes and flake-parts for modular, reproducible system configuration. It includes:
- System-level NixOS configurations
- Home Manager for user environment management
- Custom NixOS modules for services and security
- Modern CLI tools and development environment setup

## Common Development Commands

### System Rebuild and Management
```bash
# Rebuild and switch to new configuration
sudo nixos-rebuild switch --flake .#nixos

# Test configuration without switching
sudo nixos-rebuild test --flake .#nixos

# Build configuration without activating
sudo nixos-rebuild build --flake .#nixos

# Check flake configuration for errors
nix flake check

# Show flake structure and outputs
nix flake show
```

### Flake Updates and Maintenance
```bash
# Update all flake inputs to latest versions
nix flake update

# Update specific input only
nix flake lock --update-input nixpkgs

# Garbage collection to free disk space
sudo nix-collect-garbage -d

# List system generations
sudo nix-env --list-generations --profile /nix/var/nix/profiles/system

# Optimize nix store
nix-store --optimise
```

### Development
```bash
# Enter development shell with Nix tools
nix develop

# Format Nix files
nixpkgs-fmt <file.nix>

# Lint Nix files for common issues
statix check

# Find dead Nix code
deadnix
```

## Architecture Overview

### Flake Structure
- **flake.nix**: Main entry point using flake-parts for modular organization. Defines nixosConfigurations, devShells, overlays, and formatter.
- **flake.lock**: Pins all dependencies for reproducible builds.

### Key Directories
- **hosts/**: Host-specific configurations
  - Each host has `configuration.nix` (system config) and `hardware-configuration.nix` (hardware settings)
  - Currently configured host: "nixos" (default)

- **home/**: Home Manager user configurations
  - `default.nix` defines user packages, dotfiles, and program configurations
  - Manages shells (fish, zsh, bash), development tools (neovim, vscode), and desktop apps

- **modules/**: Reusable NixOS modules
  - `system/`: System-wide modules (e.g., security hardening)
  - `services/`: Service configurations (e.g., Docker setup)
  - Modules are imported but not yet activated in the default configuration

### Configuration Patterns
1. **Flake Inputs**: Uses nixpkgs stable (24.11), nixpkgs-unstable, home-manager, flake-parts, nixos-hardware, and disko
2. **Overlay System**: Unstable packages accessible via `unstable.<package>` (e.g., `unstable.claude-code`)
3. **Modern CLI Tools**: Extensive collection of Rust-based modern CLI replacements (bat, ripgrep, fd, exa, etc.)
4. **Shell Aliases**: Configured to use modern tool replacements by default
5. **Home Manager Integration**: Runs as a NixOS module for unified system management

### Important Configuration Details
- **Default User**: "user" (defined in hosts/default/configuration.nix and home/default.nix)
- **Default Shell**: Fish shell with starship prompt
- **Experimental Features**: Flakes and nix-command are enabled
- **Binary Caches**: nixos.org and nix-community configured for faster builds
- **Garbage Collection**: Weekly automatic cleanup keeping 30 days of history

## Adding New Configurations

### To add a new host:
1. Create directory under `hosts/<hostname>/`
2. Copy and modify configuration files from `hosts/default/`
3. Add nixosConfiguration entry in flake.nix
4. Rebuild with `sudo nixos-rebuild switch --flake .#<hostname>`

### To enable custom modules:
Import modules in host configuration and set their enable options:
```nix
imports = [
  ../../modules/system/security.nix
  ../../modules/services/docker.nix
];

modules.system.security.enable = true;
modules.services.docker.enable = true;
```