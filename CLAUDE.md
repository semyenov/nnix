# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Type

This is a **NixOS configuration repository** using Nix Flakes for modular, reproducible system configuration. It includes:
- System-level NixOS configurations with multiple host profiles
- Home Manager for user environment management
- Custom profiles for features (GNOME, NVIDIA, Docker, security, optimizations)
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

# Rollback to previous generation
sudo nixos-rebuild switch --rollback
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

# Delete old generations (keep last 5)
sudo nix-env --delete-generations +5 --profile /nix/var/nix/profiles/system

# Optimize nix store
nix-store --optimise
```

### Development and Testing
```bash
# Enter development shell with Nix tools
nix develop

# Format Nix files
nixpkgs-fmt <file.nix>

# Format all Nix files in repository
nix fmt

# Lint Nix files for common issues
statix check

# Find dead Nix code
deadnix

# Formatters available
# - nixpkgs-fmt (default formatter)
# - alejandra (alternative Nix formatter)

# Language server
# - nil (Nix LSP)

# Build custom packages
nix build .#packages.x86_64-linux.cursor-appimage
nix build .#packages.x86_64-linux.yandex-music

# Show all available outputs
nix flake show --all-systems

# Check flake metadata and inputs
nix flake metadata

# Search for packages in nixpkgs
nix search nixpkgs <package-name>
```

## Pre-installed Development Tools

### IDE and Editors (via desktop profile)
- **cursor-appimage**: Cursor editor AppImage
- **claude-code**: Claude Code from unstable channel
- **jetbrains.idea-community**: IntelliJ IDEA Community Edition
- **postman**: API development platform
- **neovim**: Default text editor

### Modern CLI Tools (via desktop profile)
- **Shell enhancements**: starship, direnv, atuin, mcfly, zellij
- **File managers**: broot, xplr, ranger, mc
- **Git tools**: gh-dash, gitu, lazygit, delta, difftastic, tig
- **Database clients**: pgcli, litecli, mycli
- **System info**: onefetch, scc, neofetch
- **Data visualization**: visidata, silicon

### System Administration (via sysadmin profile)
- **Monitoring**: btop, htop, glances, procs, bandwhich
- **Network**: nmap, tcpdump, mtr, dig, dog, trippy
- **Containers**: lazydocker, dive, kubectl, k9s, helm
- **Infrastructure**: terraform, ansible, vault
- **Cloud CLIs**: awscli2, google-cloud-sdk, azure-cli
- **Text processing**: jq, yq, miller, sd
- **File utilities**: lsd, eza, fd, ripgrep, bat, dust, duf

## Architecture Overview

### Flake Structure
- **flake.nix**: Main entry point defining nixosConfigurations, devShells, overlays, packages, and formatter
- **flake.lock**: Pins all dependencies for reproducible builds
- Uses nixpkgs 25.05 (stable) with nixpkgs-unstable overlay

### Key Directories
- **hosts/**: Host-specific configurations
  - `default/`: Main host with configuration.nix and hardware-configuration.nix
  - Currently configured host: "nixos"

- **home/**: Home Manager user configurations
  - `users/`: User-specific configurations (semyenov.nix)
  - `profiles/`: Reusable profile modules
    - `desktop.nix`: Desktop applications and GUI tools
    - `sysadmin.nix`: System administration tools

- **profiles/**: System-level configuration profiles
  - `gnome.nix`: GNOME desktop environment
  - `nvidia.nix`: NVIDIA GPU drivers and settings
  - `docker.nix`: Docker container runtime
  - `security.nix`: Security hardening settings
  - `optimizations.nix`: System performance optimizations

- **modules/**: Reusable NixOS modules (currently unused)
  - `system/security.nix`: Security hardening module
  - `services/docker.nix`: Docker service module

- **packages/**: Custom package definitions
  - `cursor-appimage.nix`: Cursor editor AppImage
  - `yandex-music.nix`: Yandex Music application

- **overlays/**: Package overlays
  - Provides unstable packages via `unstable.<package>`

### Configuration Patterns
1. **Flake Inputs**:
   - nixpkgs (25.05): Stable channel
   - nixpkgs-unstable: Latest packages
   - home-manager (25.05): User environment management
   - nixos-hardware: Hardware-specific optimizations

2. **User Configuration**:
   - Primary user: "semyenov"
   - Home directory: `/home/semyenov`
   - Git configured with user details
   - Direnv with nix-direnv for development environments

3. **System Features**:
   - Boot: systemd-boot with 5 generation limit
   - Networking: NetworkManager with firewall enabled
   - Desktop: GNOME with NVIDIA drivers
   - Containers: Docker support
   - Development: Full Nix development shell

### Important Configuration Details
- **Host Name**: "nixos"
- **Time Zone**: UTC
- **Locale**: en_US.UTF-8
- **Shell**: Fish with starship prompt (configured in home profiles)
- **Editor**: Neovim as default (EDITOR=nvim)
- **Browser**: Brave (BROWSER=brave)
- **Terminal**: Ghostty (TERMINAL=ghostty)
- **Experimental Features**: Flakes and nix-command enabled
- **State Version**: 25.05 (both system and home-manager)
- **Boot**: systemd-boot with 5 generation limit, 3 second timeout
- **Allowed Unfree**: Enabled globally

## Adding New Configurations

### To add a new host:
1. Create directory under `hosts/<hostname>/`
2. Copy and modify configuration files from `hosts/default/`
3. Add nixosConfiguration entry in flake.nix:
   ```nix
   nixosConfigurations.<hostname> = nixpkgs.lib.nixosSystem {
     system = "x86_64-linux";
     specialArgs = { inherit inputs; };
     modules = [ /* your modules */ ];
   };
   ```
4. Rebuild with `sudo nixos-rebuild switch --flake .#<hostname>`

### To modify user configuration:
1. Edit `home/users/semyenov.nix` for user-specific settings
2. Modify `home/profiles/desktop.nix` for desktop applications
3. Modify `home/profiles/sysadmin.nix` for system tools
4. Changes apply on next rebuild

### To use system profiles:
Profiles are imported in `hosts/default/configuration.nix`:
- Add/remove imports for different profiles
- Each profile is self-contained and can be toggled independently
- Current active profiles: gnome, nvidia, docker, security, optimizations

### Claude Code Permissions
This repository has pre-configured Claude Code permissions in `.claude/settings.local.json`:
- **Auto-allowed commands**: nix flake operations, git operations, systemd utilities
- **Additional directory access**: `/home/semyenov/.config`
- These permissions enable Claude Code to perform system administration tasks seamlessly