# NixOS Configuration with Flakes

A modern, modular NixOS configuration using Nix Flakes with a clean domain-based structure.

## Features

- **Flake-based Configuration**: Pure, reproducible system configuration
- **Domain-Organized Structure**: Clear separation of concerns with self-contained profiles
- **Home Manager Integration**: Declarative user environment management
- **Configurable Profiles**: Each profile has its own NixOS options
- **Security Hardening**: Comprehensive security profile with configurable options
- **Modern CLI Tools**: Latest terminal utilities and productivity tools
- **Development Ready**: Pre-configured IDEs and development environments

## Structure

```
.
├── flake.nix                 # Main flake entry point
├── flake.lock               # Lock file for reproducible builds
├── hosts/                   # Host-specific configurations
│   └── default/            # Default host configuration
│       ├── configuration.nix # Minimal host config (imports profiles)
│       └── hardware-configuration.nix # Hardware-specific settings
├── home/                   # Home-manager configurations
│   ├── users/             # User-specific configurations
│   │   └── semyenov.nix  # User configuration
│   └── profiles/          # Reusable home-manager profiles
│       ├── cli.nix    # Modern CLI tools
│       ├── development.nix  # Development tools
│       ├── productivity.nix # Office and media apps
│       └── sysadmin.nix     # System administration tools
├── profiles/              # System-level configuration profiles
│   ├── core.nix          # Boot, networking, nix settings
│   ├── users.nix         # User account management
│   ├── audio.nix         # PipeWire audio configuration
│   ├── fonts.nix         # Font packages and settings
│   ├── terminals.nix     # Terminal emulators
│   ├── gnome.nix         # GNOME desktop environment
│   ├── nvidia.nix        # NVIDIA GPU drivers with PRIME
│   ├── docker.nix        # Docker container runtime
│   ├── security.nix      # Security hardening
│   ├── optimizations.nix # Performance tuning
│   └── default.nix       # Imports all profiles with defaults
├── overlays/             # Package overlays
└── packages/            # Custom package definitions
    ├── cursor-appimage.nix # Cursor editor
    └── yandex-music.nix   # Yandex Music app
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

3. **Customize profiles** (optional):
   - Edit `profiles/core.nix` to change hostname, timezone, locale
   - Edit `profiles/users.nix` to change primary user
   - Toggle profiles in `profiles/default.nix`

4. **Build and switch**:
   ```bash
   # Build and activate the configuration
   sudo nixos-rebuild switch --flake .#nixos
   ```

## Profile System

### System Profiles

All system profiles are in `profiles/` and are self-contained with their own options:

```nix
# Example: Disable a profile
profiles.docker.enable = false;

# Example: Configure profile options
profiles.nvidia.prime.intelBusId = "PCI:0:2:0";
profiles.nvidia.prime.nvidiaBusId = "PCI:1:0:0";

# Example: Security options
profiles.security.enableAppArmor = true;
profiles.security.sshHardening = false;
```

Available profiles:
- **core**: Essential system configuration (boot, networking, nix)
- **users**: User account management
- **audio**: PipeWire audio with optional JACK support
- **fonts**: System fonts including Nerd Fonts
- **terminals**: Terminal emulators (alacritty, kitty, ghostty)
- **gnome**: GNOME desktop environment
- **nvidia**: NVIDIA GPU drivers with PRIME offloading
- **docker**: Docker container runtime with NVIDIA support
- **security**: Comprehensive security hardening
- **optimizations**: Performance tuning and optimizations (toggle via `profiles.optimizations.enable`)

### Home-Manager Profiles

User profiles are in `home/profiles/`:
- **cli**: Modern CLI replacements (lsd, bat, ripgrep, etc.)
- **development**: IDEs, version control, databases
- **productivity**: Browsers, office suite, media apps
- **sysadmin**: Monitoring, cloud CLIs, infrastructure tools

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

3. Customize profile options in the new host configuration:
   ```nix
   # hosts/laptop/configuration.nix
   {
     imports = [
       ./hardware-configuration.nix
       ../../profiles
     ];

     # Customize profiles for this host
     profiles.core.hostName = "laptop";
     profiles.nvidia.enable = false;  # No NVIDIA GPU
     profiles.optimizations.enable = true;
   }
   ```

4. Add the host to `flake.nix`:
   ```nix
   nixosConfigurations.laptop = nixpkgs.lib.nixosSystem {
     system = "x86_64-linux";
     specialArgs = { inherit inputs; };
     modules = [ ./hosts/laptop/configuration.nix ];
   };
   ```

### Customizing Profiles

Each profile can be configured via options:

```nix
# In your host configuration
{
  # Core settings
  profiles.core = {
    hostName = "myhost";
    timeZone = "America/New_York";
    locale = "en_US.UTF-8";
  };

  # Docker with specific users
  profiles.docker = {
    enable = true;
    enableNvidia = false;  # No GPU support needed
    users = [ "alice" "bob" ];
  };

  # Security with custom settings
  profiles.security = {
    enable = true;
    enableFirewall = true;
    enableAppArmor = false;
    sshHardening = true;
  };
}
```

### Shell Aliases

The configuration includes modern CLI tool aliases by default:

- `ls`, `ll`, `la` → `lsd` (modern ls)
- `cat` → `bat` (cat with syntax highlighting)
- `grep` → `rg` (ripgrep)
- `find` → `fd` (modern find)
- `sed` → `sd` (simpler sed)
- `du` → `dust` (visual disk usage)
- `df` → `duf` (better df)
- `ps` → `procs` (modern ps)
- `top`/`htop` → `btm` (bottom)
- `dig` → `dog` (modern DNS client)

NixOS shortcuts:
- `rebuild` → Rebuild system configuration
- `update` → Update flake inputs
- `clean` → Garbage collect
- `generations` → List system generations

## Development Environment

The flake includes a development shell with Nix tools:

```bash
nix develop
```

Available tools:
- `nixpkgs-fmt` - Format Nix files
- `alejandra` - Alternative Nix formatter
- `statix` - Lint Nix files
- `deadnix` - Find dead Nix code
- `nil` - Nix language server

## Tips and Tricks

### Fast Iteration

For quick testing without rebuilding the entire system:
```bash
# Test a specific package
nix build .#packages.x86_64-linux.cursor-appimage

# Check configuration without building
nix flake check
```

### Performance Optimization

The `optimizations.nix` profile (enabled by default in `profiles/default.nix`) includes:
- ZRAM swap compression
- Kernel performance tuning
- SystemD optimization
- EarlyOOM for memory management
- I/O scheduler tuning
- Tmpfs for /tmp

Disable it per host if needed:
```nix
profiles.optimizations.enable = false;
```

### Security Hardening

The `security.nix` profile provides:
- Kernel hardening with sysctl tweaks
- SSH hardening with strong crypto
- Fail2ban for brute force protection
- Audit daemon with file monitoring
- AppArmor support (optional)
- Firewall with logging

## Troubleshooting

### Build Failures

```bash
# Check the flake
nix flake check

# Build with more verbosity
sudo nixos-rebuild switch --flake .#nixos --show-trace

# See what changed
nix diff-closures /run/current-system result
```

### Out of Disk Space

```bash
# Clean up everything
sudo nix-collect-garbage -d
sudo nix-store --optimise

# Remove specific generations
sudo nix-env --delete-generations 7d --profile /nix/var/nix/profiles/system
```

### Profile Conflicts

If profiles conflict, you can:
1. Disable conflicting profiles in `profiles/default.nix`
2. Override settings in your host configuration
3. Use `mkForce` to override values:
   ```nix
   services.xserver.videoDrivers = lib.mkForce [ "intel" ];
   ```

## Resources

- [NixOS Manual](https://nixos.org/manual/nixos/stable/)
- [Nix Flakes Documentation](https://nixos.wiki/wiki/Flakes)
- [Home Manager Manual](https://nix-community.github.io/home-manager/)
- [NixOS Options Search](https://search.nixos.org/options)
- [Nix Package Search](https://search.nixos.org/packages)

## License

Feel free to use and modify this configuration for your own needs!