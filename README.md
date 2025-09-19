# NixOS Configuration with Flakes

A modern, modular NixOS configuration using Nix Flakes and flake-parts, inspired by awesome community configurations.

## Features

- **Flake-based Configuration**: Pure, reproducible system configuration
- **Modular Structure**: Organized with flake-parts for better maintainability
- **Home Manager Integration**: Declarative user environment management
- **Custom Modules**: Reusable system and service modules
- **Security Hardening**: Optional security enhancements module
- **Development Ready**: Pre-configured development environments

## Structure

```
.
├── flake.nix                 # Main flake entry point with flake-parts
├── flake.lock               # Lock file for reproducible builds
├── hosts/                   # Host-specific configurations
│   └── default/            # Default host configuration
│       ├── configuration.nix # System configuration
│       └── hardware-configuration.nix # Hardware-specific settings
├── home/                   # Home-manager configurations  
│   └── default.nix        # Default user environment
├── modules/                # Reusable NixOS modules
│   ├── system/           # System-wide modules
│   │   └── security.nix # Security hardening module
│   └── services/         # Service configurations
│       └── docker.nix   # Docker service module
├── overlays/             # Package overlays
└── packages/            # Custom package definitions
```

## Quick Start

### Prerequisites

1. **NixOS Installation**: This configuration assumes you have NixOS installed
2. **Enable Flakes**: Flakes need to be enabled in your current configuration

### Initial Setup

1. **Clone this configuration**:
   ```bash
   git clone <your-repo> ~/nixos-config
   cd ~/nixos-config
   ```

2. **Generate hardware configuration** for your machine:
   ```bash
   sudo nixos-generate-config --show-hardware-config > hosts/default/hardware-configuration.nix
   ```

3. **Update configuration**:
   - Edit `hosts/default/configuration.nix`:
     - Set your hostname
     - Set your timezone
     - Configure your user account
   - Edit `home/default.nix`:
     - Set your git username and email
     - Customize installed packages

4. **Build and switch**:
   ```bash
   # Build and activate the configuration
   sudo nixos-rebuild switch --flake .#nixos
   
   # Or for a specific host
   sudo nixos-rebuild switch --flake .#<hostname>
   ```

## Common Commands

### System Management

```bash
# Rebuild and switch to new configuration
sudo nixos-rebuild switch --flake .#nixos

# Test configuration without switching
sudo nixos-rebuild test --flake .#nixos

# Build configuration without activating
sudo nixos-rebuild build --flake .#nixos

# Rollback to previous generation
sudo nixos-rebuild switch --rollback
```

### Flake Commands

```bash
# Update all flake inputs
nix flake update

# Update specific input
nix flake lock --update-input nixpkgs

# Check flake configuration
nix flake check

# Show flake info
nix flake show

# Enter development shell
nix develop
```

### Maintenance

```bash
# Garbage collection
sudo nix-collect-garbage -d

# List system generations
sudo nix-env --list-generations --profile /nix/var/nix/profiles/system

# Delete old generations (keep last 5)
sudo nix-env --delete-generations +5 --profile /nix/var/nix/profiles/system

# Optimize nix store
nix-store --optimise
```

## Configuration Guide

### Adding a New Host

1. Create a new directory under `hosts/`:
   ```bash
   mkdir -p hosts/laptop
   ```

2. Copy and modify configuration files:
   ```bash
   cp hosts/default/*.nix hosts/laptop/
   ```

3. Add the host to `flake.nix`:
   ```nix
   nixosConfigurations = {
     laptop = nixpkgs.lib.nixosSystem {
       system = "x86_64-linux";
       # ... configuration
     };
   };
   ```

### Using Custom Modules

Enable custom modules in your host configuration:

```nix
# In hosts/default/configuration.nix
{
  imports = [
    ./hardware-configuration.nix
    ../../modules/system/security.nix
    ../../modules/services/docker.nix
  ];
  
  # Enable modules
  modules.system.security.enable = true;
  modules.services.docker = {
    enable = true;
    users = [ "youruser" ];
  };
}
```

### Home Manager Configuration

User-specific configurations are in `home/default.nix`. To add packages or configure programs:

```nix
home.packages = with pkgs; [
  firefox
  vscode
  # Add more packages
];

programs.git = {
  enable = true;
  userName = "Your Name";
  userEmail = "you@example.com";
};
```

## Tips and Tricks

### Development Environments

Use the included dev shell for NixOS development:
```bash
nix develop
```

This provides tools like:
- `nixpkgs-fmt` - Format Nix files
- `statix` - Lint Nix files  
- `deadnix` - Find dead Nix code
- `nil` - Nix language server

### Fast Iteration

For quick testing without rebuilding the entire system:
```bash
# Test a specific package
nix build .#packages.x86_64-linux.<package-name>

# Test home-manager configuration
home-manager switch --flake .#user
```

### Secrets Management

For managing secrets, consider using:
- [agenix](https://github.com/ryantm/agenix) - age-encrypted secrets
- [sops-nix](https://github.com/Mic92/sops-nix) - SOPS with various backends

### Performance Optimization

1. **Use binary caches**: Already configured in the flake
2. **Enable auto-optimization**: Set in nix.settings
3. **Regular maintenance**: Run garbage collection weekly
4. **Limit generations**: Keep only necessary system generations

## Troubleshooting

### Flakes Not Enabled

If you get an error about experimental features:
```bash
# Temporarily enable flakes
nix --experimental-features 'nix-command flakes' flake show

# Or add to your current configuration
nix.settings.experimental-features = [ "nix-command" "flakes" ];
```

### Out of Disk Space

```bash
# Clean up old generations and garbage collect
sudo nix-collect-garbage -d
sudo nix-store --optimise
```

### Build Failures

```bash
# Check the flake
nix flake check

# Build with more verbosity
sudo nixos-rebuild switch --flake .#nixos --show-trace

# Build with even more details
sudo nixos-rebuild switch --flake .#nixos --show-trace --verbose
```

## Resources

- [NixOS Manual](https://nixos.org/manual/nixos/stable/)
- [Nix Flakes Documentation](https://nixos.wiki/wiki/Flakes)
- [Home Manager Manual](https://nix-community.github.io/home-manager/)
- [flake-parts Documentation](https://flake.parts/)
- [Awesome Nix](https://github.com/nix-community/awesome-nix)

## Community Configurations

This configuration was inspired by:
- [Misterio77/nix-starter-configs](https://github.com/Misterio77/nix-starter-configs)
- [Mic92/dotfiles](https://github.com/Mic92/dotfiles)
- [fufexan/dotfiles](https://github.com/fufexan/dotfiles)
- [flake-parts examples](https://github.com/hercules-ci/flake-parts-website/tree/main/examples)

## License

Feel free to use and modify this configuration for your own needs!