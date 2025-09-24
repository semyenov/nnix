# System Modules

This directory contains self-contained NixOS system modules. Each module has its own sozdev options that can be enabled, disabled, and configured independently.

## Module Structure

Each module follows this pattern:

```nix
{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.sozdev.<name>;
in
{
  options.sozdev.<name> = {
    enable = mkEnableOption "Description" // {
      default = true;  # or false
    };
    # Additional options...
  };

  config = mkIf cfg.enable {
    # Configuration when enabled
  };
}
```

## Available Profiles

### Core System (`core.nix`)
Essential system configuration including boot, networking, and Nix settings.

**Options:**
- `sozdev.core.enable` - Enable core configuration (default: true)
- `sozdev.core.hostName` - System hostname (default: "nixos")
- `sozdev.core.timeZone` - System timezone (default: "UTC")
- `sozdev.core.locale` - System locale (default: "en_US.UTF-8")

**Provides:**
- Boot loader (systemd-boot)
- Network configuration (NetworkManager)
- Nix flakes and experimental features
- Shell aliases for modern CLI tools
- Essential system packages (gopass, nekoray)

### User Management (`users.nix`)
User account configuration.

**Options:**
- `sozdev.users.enable` - Enable user management (default: true)
- `sozdev.users.primaryUser` - Primary user name (default: "semyenov")

**Provides:**
- User account with sudo privileges
- User groups (wheel, networkmanager, audio, video, docker, libvirtd)
- Fish shell as default

### Audio (`audio.nix`)
PipeWire audio system configuration.

**Options:**
- `sozdev.audio.enable` - Enable audio support (default: true)
- `sozdev.audio.enableJack` - Enable JACK support (default: true)

**Provides:**
- PipeWire with PulseAudio/ALSA/JACK compatibility
- RealtimeKit for low-latency audio
- 32-bit application support

### Fonts (`fonts.nix`)
System font configuration.

**Options:**
- `sozdev.fonts.enable` - Enable font configuration (default: true)
- `sozdev.fonts.nerdFonts` - List of Nerd Fonts to install (default: ["RecursiveMono"])

**Provides:**
- Nerd Fonts for terminal icons
- Noto fonts (including CJK and emoji)
- Liberation fonts
- Fontconfig with sensible defaults

### Terminal Emulators (`terminals.nix`)
Terminal emulator applications.

**Options:**
- `sozdev.terminals.enable` - Enable terminal emulators (default: true)

**Provides:**
- Alacritty - GPU-accelerated terminal
- Kitty - Feature-rich terminal
- Ghostty - Modern terminal emulator

### GNOME Desktop (`gnome.nix`)
GNOME desktop environment.

**Options:**
- `sozdev.gnome.enable` - Enable GNOME desktop (default: true)
- `sozdev.gnome.wayland` - Enable Wayland support (default: true)

**Provides:**
- GNOME desktop environment
- GDM display manager
- GNOME extensions (AppIndicator, Dash to Dock, etc.)
- Bluetooth support
- Printing support
- GNOME keyring

### NVIDIA GPU (`nvidia.nix`)
NVIDIA GPU driver configuration.

**Options:**
- `sozdev.nvidia.enable` - Enable NVIDIA support (default: true)
- `sozdev.nvidia.prime.enable` - Enable PRIME offloading (default: true)
- `sozdev.nvidia.prime.intelBusId` - Intel GPU PCI bus ID (default: "PCI:0:2:0")
- `sozdev.nvidia.prime.nvidiaBusId` - NVIDIA GPU PCI bus ID (default: "PCI:1:0:0")

**Provides:**
- NVIDIA proprietary drivers
- PRIME GPU offloading
- 32-bit driver support
- Modesetting and power management

### Docker (`docker.nix`)
Docker container runtime.

**Options:**
- `sozdev.docker.enable` - Enable Docker (default: false)
- `sozdev.docker.enableOnBoot` - Start Docker on boot (default: true)
- `sozdev.docker.enableNvidia` - Enable NVIDIA GPU support (default: true)
- `sozdev.docker.storageDriver` - Storage driver (default: "overlay2")
- `sozdev.docker.dockerComposePackage` - Docker Compose package to use
- `sozdev.docker.users` - Users to add to docker group (default: ["semyenov"])

**Provides:**
- Docker daemon with experimental features
- Docker Compose
- Container management tools (lazydocker, dive, ctop)
- Weekly automatic pruning
- Docker shell aliases
- NVIDIA container toolkit (when enabled)

### Security Hardening (`security.nix`)
Comprehensive security configuration.

**Options:**
- `sozdev.security.enable` - Enable security hardening (default: true)
- `sozdev.security.enableFirewall` - Enable firewall (default: true)
- `sozdev.security.enableAppArmor` - Enable AppArmor (default: false)
- `sozdev.security.sshHardening` - Apply SSH hardening (default: true)

**Provides:**
- Kernel hardening (sysctl parameters)
- SSH hardening with strong cryptography
- Fail2ban for brute force protection
- Audit daemon with file monitoring
- Firewall with logging
- Sudo configuration with insults
- Security tools (lynis, aide, chkrootkit)

### Performance Optimizations (`optimizations.nix`)
System performance tuning (toggleable).

**Options:**
- `sozdev.optimizations.enable` - Enable performance optimizations (default: true via `modules/default.nix`)

**Provides:**
- ZRAM swap compression (25% of RAM)
- Kernel performance parameters
- I/O scheduler optimization
- SystemD optimizations
- EarlyOOM for memory management
- Tmpfs for /tmp
- Network optimizations (BBR congestion control)
- Automatic store optimization

### Gaming (`gaming.nix`)
Gaming tweaks and tooling.

**Options:**
- `sozdev.gaming.enable` - Enable gaming stack (default: false)
- `sozdev.gaming.openCSPorts` - Open common CS 1.6 ports (default: false)
- `sozdev.gaming.steamPackage` - Steam package to use (default: `pkgs.steam`)

**Provides:**
- 32-bit graphics and Vulkan support
- Steam (Remote Play firewall opened)
- Feral GameMode for performance
- MangoHud overlay
- Optional firewall ports for CS 1.6
- Common tools: Lutris, ProtonUp-Qt, Wine, Winetricks, Vulkan tools

## Usage

### In Host Configuration

Import all profiles with defaults:

```nix
# hosts/semyenov/configuration.nix
{
  imports = [
    ./hardware-configuration.nix
    ../../modules  # Imports modules/default.nix
  ];
}
```

### Customizing Profiles

Override profile settings in your host configuration:

```nix
{
  # Disable specific profiles
  sozdev.docker.enable = false;

  # Configure profile options
  sozdev.core = {
    hostName = "semyenov";
    timeZone = "Europe/Moscow";
  };

  sozdev.nvidia.prime = {
    intelBusId = "PCI:0:2:0";
    nvidiaBusId = "PCI:2:0:0";
  };
}
```

### Creating New Profiles

1. Create a new file in `profiles/`:

```nix
# profiles/myprofile.nix
{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.sozdev.myprofile;
in
{
  options.sozdev.myprofile = {
    enable = mkEnableOption "My custom profile";

    someOption = mkOption {
      type = types.str;
      default = "value";
      description = "Some configurable option";
    };
  };

  config = mkIf cfg.enable {
    # Your configuration here
  };
}
```

2. Add it to `modules/default.nix`:

```nix
{
  imports = [
    # ... existing profiles
    ./myprofile.nix
  ];

  sozdev.myprofile.enable = true;  # or false for opt-in
}
```

## Best Practices

1. **Keep profiles focused**: Each profile should handle one domain
2. **Use options**: Make profiles configurable via options
3. **Set sensible defaults**: Profiles should work out-of-the-box
4. **Document options**: Use `description` field for all options
5. **Handle conflicts**: Use `mkForce` when necessary
6. **Test independently**: Profiles should work when enabled alone

## Profile Dependencies

Some profiles may depend on or interact with others:

- `nvidia.nix` sets video drivers used by `gnome.nix`
- `docker.nix` can use NVIDIA container toolkit from `nvidia.nix`
- `security.nix` may override settings from other profiles
- `optimizations.nix` affects system-wide performance

When conflicts arise, later imports take precedence, or use `mkForce` to override.