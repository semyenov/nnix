# Home Manager Profiles

This directory contains reusable Home Manager profiles for user environment configuration. Each profile focuses on a specific domain and can be imported independently.

## Available Profiles

### CLI Tools (`cli-tools.nix`)
Modern command-line tools and shell enhancements.

**Includes:**
- **Shell Enhancements**: starship, direnv, atuin, mcfly, zellij, navi, vivid
- **Modern CLI Replacements**:
  - `lsd`, `eza` - Modern ls alternatives
  - `fd` - Modern find
  - `ripgrep` - Fast grep
  - `bat` - Cat with syntax highlighting
  - `dust` - Visual disk usage
  - `duf` - Better df
  - `procs`, `btop`, `bottom` - Process viewers
  - `dog` - Modern DNS client
  - `sd` - Intuitive sed alternative
  - `miller` - CSV/JSON processor
- **File Managers**: broot, xplr, ranger, mc, ncdu, dua
- **Terminal Utilities**: tmux, screen, mosh, asciinema, expect
- **Data Processing**: jq, yq, visidata, silicon
- **System Info**: neofetch, onefetch, hardware info tools
- **Archives**: p7zip, unrar, zip, unzip
- **Fun**: cowsay, lolcat, cmatrix

**Configuration:**
- Sets environment variables (EDITOR, BROWSER, TERMINAL)
- Enables direnv with nix-direnv integration

### Development (`development.nix`)
Development tools and IDEs.

**Includes:**
- **IDEs and Editors**:
  - Cursor (AppImage)
  - Claude Code (from unstable)
  - IntelliJ IDEA Community
  - Postman
  - Neovim
- **Version Control**:
  - GitHub CLI (gh), GitLab CLI
  - Git UIs: gh-dash, gitu, lazygit
  - Diff tools: delta, difftastic, tig
- **Database Clients**:
  - PostgreSQL, MariaDB, Redis
  - Interactive clients: pgcli, mycli, litecli
- **Debugging & Profiling**:
  - gdb, valgrind, hyperfine
  - strace, ltrace
- **Documentation**: cheat, tealdeer (tldr)
- **Code Analysis**: scc (code counter), onefetch (git info)

### Productivity (`productivity.nix`)
Office, communication, and media applications.

**Includes:**
- **Communication**: Telegram Desktop, Thunderbird
- **Browsers**: Brave, Chromium
- **Office & Documentation**: Obsidian, LibreOffice
- **Media**:
  - Players: VLC, Spotify, Yandex Music
  - Editors: GIMP, Inkscape
  - Recording: OBS Studio
- **System Utilities**: dconf, GNOME Tweaks

### System Administration (`sysadmin.nix`)
Tools for system administration and DevOps.

**Includes:**
- **Monitoring**:
  - htop, iotop-c, nethogs, iftop, bmon
  - glances, sysstat, lsof
  - bandwhich, trippy
- **Network Tools**:
  - nmap, tcpdump, mtr, traceroute
  - dig, whois, netcat, socat, iperf3
- **Security Tools**:
  - lynis, aide, chkrootkit
  - age, sops, pass, pwgen, gnupg
- **Container Management**:
  - lazydocker, dive
  - kubectl, k9s, helm
- **Infrastructure as Code**:
  - terraform, ansible, vault
- **Cloud CLIs**:
  - AWS CLI v2
  - Google Cloud SDK
  - Azure CLI
- **Backup Tools**:
  - restic, borgbackup
  - rclone, rsync
- **Log Analysis**: lnav, multitail

## Usage

### In User Configuration

Import profiles in your user configuration:

```nix
# home/users/myuser.nix
{ config, pkgs, lib, inputs, ... }:

{
  home = {
    username = "myuser";
    homeDirectory = "/home/myuser";
    stateVersion = "25.05";
  };

  imports = [
    ../profiles/cli-tools.nix
    ../profiles/development.nix
    ../profiles/productivity.nix
    ../profiles/sysadmin.nix
  ];

  # Additional user-specific configuration
  programs.git = {
    enable = true;
    userName = "Your Name";
    userEmail = "you@example.com";
  };
}
```

### Selective Imports

Import only the profiles you need:

```nix
{
  imports = [
    ../profiles/cli-tools.nix     # Always useful
    ../profiles/development.nix   # For developers
    # ../profiles/productivity.nix  # Skip if using different apps
    # ../profiles/sysadmin.nix      # Only for system administrators
  ];
}
```

### Creating New Profiles

1. Create a new file in `home/profiles/`:

```nix
# home/profiles/myprofile.nix
{ config, pkgs, lib, inputs, ... }:

{
  home.packages = with pkgs; [
    package1
    package2
  ];

  programs.myprogram = {
    enable = true;
    # Configuration
  };

  home.file.".config/myapp/config".text = ''
    configuration content
  '';
}
```

2. Import it in user configuration:

```nix
{
  imports = [
    ../profiles/myprofile.nix
  ];
}
```

## Package Organization Guidelines

When adding packages to profiles:

1. **Group by functionality**: Keep related tools together
2. **Add comments**: Explain what package groups do
3. **Consider dependencies**: Some tools may need configuration beyond just installation
4. **Avoid conflicts**: Don't install multiple tools that serve the exact same purpose
5. **Use unstable carefully**: Only use unstable channel when necessary

## Environment Variables

Common environment variables are set in `cli-tools.nix`:

```nix
home.sessionVariables = {
  EDITOR = "nvim";
  BROWSER = "brave";
  TERMINAL = "ghostty";
};
```

Override these in your user configuration if needed:

```nix
home.sessionVariables = {
  EDITOR = "vim";
  BROWSER = "firefox";
};
```

## Tips

1. **Start minimal**: Begin with `cli-tools.nix` and add more as needed
2. **Review packages**: Periodically review installed packages and remove unused ones
3. **Custom configs**: Add program-specific configurations in user files
4. **Dotfiles**: Use `home.file` to manage dotfiles declaratively
5. **Test changes**: Use `home-manager switch` to test without system rebuild