# Home Manager Profiles

This directory contains reusable Home Manager profiles for user environment configuration. Each profile focuses on a specific domain and can be imported independently.

## Available Profiles

### Development (`development.nix`)
Development tools and IDEs.

**Includes:**
- **IDEs and Editors**:
  - Cursor (AppImage)
  - Claude Code (from unstable)
  - Postman (API development)
  - Neovim (default editor)
  - Helix (post-modern modal editor)
  - Zed (high-performance editor)
- **Version Control**:
  - GitHub CLI (gh), GitLab CLI
  - Git UIs: gh-dash, gitu, gitui, lazygit
  - Diff tools: delta, difftastic, tig
- **JavaScript/TypeScript**: Bun.js (fast all-in-one runtime), fnm (Node.js version manager)
- **Language Managers**: pyenv (Python), rbenv (Ruby)
- **Database Clients**:
  - PostgreSQL, MariaDB, Redis
  - Interactive clients: pgcli, mycli, litecli
- **Debugging & Profiling**:
  - gdb, valgrind, hyperfine
  - strace, ltrace
- **Documentation**: cheat, tealdeer (tldr)
- **Code Analysis**: scc (code counter)

### Productivity (`productivity.nix`)
Office, communication, and media applications.

**Includes:**
- **Communication**: Telegram Desktop, Thunderbird
- **Browsers**: Brave, Chromium
- **Office & Documentation**: Obsidian, LibreOffice
- **Media**:
  - Players: VLC, Spotify, Yandex Music, Tauon
  - Editors: GIMP, Inkscape
  - Recording: OBS Studio
- **System Utilities**: dconf, GNOME Tweaks
- **Proxy Tools**: Throne (custom proxy utility)

### Terminal (`terminal.nix`)
Modern command-line tools and shell enhancements.

**Includes:**
- **Shell Enhancements**: atuin, mcfly, zellij, navi, vivid
- **Modern CLI Replacements**:
  - `lsd`, `eza` - Modern ls alternatives
  - `fd` - Modern find
  - `ripgrep` - Fast grep
  - `bat` - Cat with syntax highlighting
  - `dust` - Visual disk usage
  - `duf` - Better df
  - `procs`, `btop`, `htop`, `glances` - Process viewers
  - `dog` - Modern DNS client
  - `sd` - Intuitive sed alternative
  - `miller` - CSV/JSON processor
  - `jq`, `yq` - JSON/YAML processors
- **File Managers**: broot, xplr, ranger, mc
- **System Info**: neofetch, onefetch
- **Network Tools**: mtr, nmap, tcpdump, bandwhich, trippy
- **Container Tools**: lazydocker, dive, kubectl, k9s, helm
- **Infrastructure Tools**: terraform, ansible, vault
- **Cloud CLIs**: AWS CLI v2, Google Cloud SDK, Azure CLI
- **Data Visualization**: visidata, silicon

### Fish Shell (`fish.nix`)
Fish shell configuration with modern aliases.

**Features:**
- Fish shell enabled by default
- Modern CLI tool aliases:
  - `ls`, `ll`, `la` → `lsd`
  - `cat` → `bat`
  - `grep` → `rg` (ripgrep)
  - `find` → `fd`
  - `sed` → `sd`
  - `du` → `dust`
  - `df` → `duf`
  - `ps` → `procs`
  - `top`/`htop` → `btm` (bottom)
  - `dig` → `dog`
- Git shortcuts:
  - `g` → `git`
  - `gg` → `gitu`
  - `lg` → `lazygit`
- NixOS shortcuts:
  - `rebuild` → `sudo nixos-rebuild switch --flake .#semyenov`
  - `update` → `nix flake update`
  - `clean` → `sudo nix-collect-garbage -d`
  - `generations` → Lists system generations
- Zoxide integration for smart directory navigation

### OMF - Oh My Fish Plugins (`omf.nix`)
Fish plugins managed via Nix (avoiding Oh My Fish framework conflicts).

**Includes:**
- **Tide**: Ultimate Fish prompt theme
  - Double-line prompt with git information
  - Customizable via `tide configure` command
  - Shows current directory, git status, command duration
- **Bang-bang**: Bash-style history substitution (!!, !$)
- **Fzf-fish**: Fuzzy finder integration for:
  - Command history search
  - File and directory search
  - Process killing
  - Git operations

### Nix Development (`nix.nix`)
Nix-specific development tools.

**Includes:**
- **Formatters**: nixpkgs-fmt, alejandra
- **Linters**: statix, deadnix
- **Language Servers**: nil
- **Development shell integration**

## Usage

### In User Configuration

Import profiles in your user configuration:

```nix
# home/users/semyenov.nix
{...}: {
  imports = [
    ../profiles/terminal.nix
    ../profiles/fish.nix
    ../profiles/omf.nix
    ../profiles/nix.nix
    ../profiles/development.nix
    ../profiles/productivity.nix
  ];

  # Additional user-specific configuration
  programs.git = {
    enable = true;
    userName = "Your Name";
    userEmail = "your@email.com";
  };
}
```

### Selective Imports

Import only the profiles you need:

```nix
{
  imports = [
    ../profiles/fish.nix        # Fish shell with aliases
    ../profiles/omf.nix         # Fish plugins and Tide prompt
    ../profiles/terminal.nix   # CLI tools
    ../profiles/nix.nix        # Nix development
    # ../profiles/development.nix  # Skip if not developing
    # ../profiles/productivity.nix # Skip if using different apps
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

Common environment variables are set via home-manager:

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

## Fish Shell Customization

### Tide Prompt Configuration

The Tide prompt can be customized interactively:

```bash
tide configure
```

This will walk you through various options for:
- Prompt style (lean, classic, rainbow)
- Icon set (with or without icons)
- Color scheme
- Prompt components

### Adding Custom Aliases

Add custom aliases to `fish.nix`:

```nix
programs.fish.shellAliases = {
  # Existing aliases...
  myalias = "my-command";
};
```

### Fish Plugins

Additional Fish plugins can be added in `omf.nix`:

```nix
home.packages = with pkgs.fishPlugins; [
  tide
  bang-bang
  fzf-fish
  # Add more plugins here
  autopair  # Auto-complete brackets
  done      # Notifications when long processes complete
];
```

## Tips

1. **Start minimal**: Begin with `fish.nix` and `omf.nix` for a good shell experience
2. **Review packages**: Periodically review installed packages and remove unused ones
3. **Custom configs**: Add program-specific configurations in user files
4. **Dotfiles**: Use `home.file` to manage dotfiles declaratively
5. **Test changes**: Use `home-manager switch` to test without system rebuild

## Troubleshooting

### Fish Plugins Not Loading

If Fish plugins aren't loading:
1. Ensure both `fish.nix` and `omf.nix` are imported
2. Restart your shell or run `exec fish`
3. Check plugin installation with `ls ~/.config/fish/conf.d/`

### Tide Prompt Not Showing

If Tide prompt isn't displaying:
1. Run `tide configure` to initialize
2. Check if the prompt is set: `echo $tide_prompt_add_newline_before`
3. Ensure terminal supports required fonts/icons

### Alias Conflicts

If aliases conflict with existing commands:
1. Use `command <name>` to bypass alias
2. Remove conflicting alias from `fish.nix`
3. Create custom alias with different name