{ config, pkgs, inputs, ... }:

{
  # Home Manager configuration for the user
  home = {
    username = "user";
    homeDirectory = "/home/user";
    
    # State version for Home Manager
    stateVersion = "24.11";

    # User packages
    packages = with pkgs; [
      # Communication
      discord
      slack
      telegram-desktop
      
      # Browsers
      brave
      chromium
      
      # Development
      vscode
      cursor-appimage  # Cursor IDE
      jetbrains.idea-community
      postman
      docker-compose
      
      # Media
      vlc
      spotify
      yandex-music  # Yandex Music desktop app
      gimp
      inkscape
      obs-studio
      
      # Productivity
      obsidian
      libreoffice
      thunderbird
      
      # System utilities
      dconf
      gnome-tweaks
      
      # CLI tools
      tmux
      starship
      direnv
      jq
      yq
      httpie
      lazygit
      lazydocker
      gh # GitHub CLI
      
      # Modern shell tools
      atuin        # Magical shell history with sync
      mcfly        # Context-aware history search
      broot        # Interactive file tree explorer
      skim         # Rust-based fzf alternative
      navi         # Interactive cheatsheet tool
      tealdeer     # Fast tldr client (rust implementation)
      zellij       # Modern tmux alternative
      
      # Development helpers
      gh-dash      # GitHub dashboard in terminal
      gitu         # Git TUI written in Rust
      silicon      # Create beautiful code screenshots
      onefetch     # Git repository summary
      scc          # Fast code counter (better than tokei for some cases)
      pgcli        # Better PostgreSQL CLI
      litecli      # Better SQLite CLI
      
      # Data tools
      visidata     # Spreadsheet in terminal
      
      # File tools
      dua          # Disk usage analyzer (alternative to ncdu)
      xplr         # Hackable file explorer
      
      # Shell enhancement tools
      vivid        # LS_COLORS generator
      
      # Fun
      neofetch
      cowsay
      lolcat
      cmatrix
    ];

    # Session variables
    sessionVariables = {
      EDITOR = "nvim";
      BROWSER = "brave";
      TERMINAL = "alacritty";
    };

    # File management
    file = {
      # Example: Create a custom config file
      # ".config/app/config.toml".text = ''
      #   setting = "value"
      # '';
    };
  };

  # Program configurations
  programs = {
    # Home Manager management
    home-manager.enable = true;

    # Git
    git = {
      enable = true;
      userName = "Your Name"; # Change this
      userEmail = "your.email@example.com"; # Change this
      
      extraConfig = {
        init.defaultBranch = "main";
        core.editor = "nvim";
        
        pull.rebase = false;
        push.autoSetupRemote = true;
        
        diff.colorMoved = "default";
        merge.conflictstyle = "diff3";
      };
      
      aliases = {
        co = "checkout";
        br = "branch";
        ci = "commit";
        st = "status";
        unstage = "reset HEAD --";
        last = "log -1 HEAD";
        lg = "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit";
      };
    };

    # Starship prompt
    starship = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
      enableFishIntegration = true;
      
      settings = {
        format = "$all$character";
        
        character = {
          success_symbol = "[➜](bold green)";
          error_symbol = "[➜](bold red)";
        };
        
        git_branch = {
          symbol = " ";
          format = "[$symbol$branch]($style) ";
        };
        
        nix_shell = {
          symbol = " ";
          format = "[$symbol$state]($style) ";
        };
        
        package.disabled = true;
      };
    };

    # Bash
    bash = {
      enable = true;
      enableCompletion = true;
      
      shellAliases = {
        ll = "ls -l";
        la = "ls -la";
        ".." = "cd ..";
        "..." = "cd ../..";
      };
      
      initExtra = ''
        # Custom bash configurations
        export PATH=$HOME/.local/bin:$PATH
        
        # Better history
        export HISTCONTROL=ignoredups:erasedups
        export HISTSIZE=10000
        export HISTFILESIZE=10000
        shopt -s histappend
        
        # Enable vi mode
        set -o vi
      '';
    };

    # Fish shell configuration
    fish = {
      enable = true;
      
      shellAliases = {
        # Modern replacements
        ll = "lsd -l";
        la = "lsd -la";
        l = "lsd -l";
        ls = "lsd";
        cat = "bat";
        grep = "rg";
        find = "fd";
        sed = "sd";
        du = "dust";
        df = "duf";
        ps = "procs";
        top = "btm";
        dig = "dog";
        
        # Git shortcuts
        g = "git";
        gg = "gitui";
        lg = "lazygit";
        
        # Quick commands
        j = "just";
        h = "hyperfine";
      };
      
      shellInit = ''
        # Set up modern tools
        set -gx EDITOR nvim
        set -gx VISUAL nvim
        set -gx PAGER "bat --style=plain"
        
        # Better colors for ls/lsd
        set -gx LS_COLORS (vivid generate molokai)
        
        # FZF configuration
        set -gx FZF_DEFAULT_COMMAND "fd --type f --hidden --follow --exclude .git"
        set -gx FZF_DEFAULT_OPTS "--height 40% --layout=reverse --border --preview 'bat --style=numbers --color=always --line-range :500 {}'"
        set -gx FZF_CTRL_T_COMMAND "$FZF_DEFAULT_COMMAND"
        
        # Zoxide init
        zoxide init fish | source
        
        # Atuin init for magical shell history
        atuin init fish | source
        
        # Starship prompt
        starship init fish | source
      '';
      
      functions = {
        # Custom greeting
        fish_greeting = ''
          echo "Welcome to Fish shell with modern CLI tools!"
          echo "Type 'navi' for an interactive cheatsheet"
          echo "Type 'tldr <command>' for quick help"
        '';
        
        # Better cd with zoxide
        cd = ''
          if count $argv > /dev/null
            z $argv
          else
            z ~
          end
        '';
        
        # Quick project finder
        proj = ''
          set selected (fd . ~/Documents ~/Projects --type d --max-depth 2 | fzf --preview "lsd -la {}")
          if test -n "$selected"
            cd $selected
          end
        '';
      };
      
      plugins = [
        # Fish plugins can be added here if using fishPlugins from nixpkgs
      ];
    };
    
    # Zsh
    zsh = {
      enable = true;
      enableCompletion = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;
      
      history = {
        size = 10000;
        share = true;
        ignoreDups = true;
      };
      
      initExtra = ''
        # Custom zsh configurations
        export PATH=$HOME/.local/bin:$PATH
        
        # Enable vi mode
        bindkey -v
        
        # Better history search
        bindkey '^R' history-incremental-search-backward
      '';
      
      plugins = [
        # Add zsh plugins here
      ];
    };

    # Neovim
    neovim = {
      enable = true;
      defaultEditor = true;
      viAlias = true;
      vimAlias = true;
      
      # Basic configuration
      extraConfig = ''
        set number relativenumber
        set expandtab
        set tabstop=2
        set shiftwidth=2
        set smartindent
        set wrap
        set ignorecase
        set smartcase
        set hlsearch
        set incsearch
        set termguicolors
        set scrolloff=8
        set sidescrolloff=8
        set mouse=a
        set clipboard=unnamedplus
        
        " Key mappings
        let mapleader = " "
        nnoremap <leader>w :w<CR>
        nnoremap <leader>q :q<CR>
        nnoremap <leader>h :nohl<CR>
      '';
      
      plugins = with pkgs.vimPlugins; [
        # Theme
        gruvbox-material
        
        # Essential plugins
        vim-sensible
        vim-surround
        vim-commentary
        vim-fugitive
        
        # File navigation
        telescope-nvim
        nvim-tree-lua
        
        # LSP and completion
        nvim-lspconfig
        nvim-cmp
        cmp-nvim-lsp
        cmp-buffer
        cmp-path
        
        # Syntax highlighting
        nvim-treesitter.withAllGrammars
        
        # Status line
        lualine-nvim
        
        # Git integration
        gitsigns-nvim
      ];
    };

    # Tmux
    tmux = {
      enable = true;
      terminal = "screen-256color";
      historyLimit = 10000;
      keyMode = "vi";
      
      extraConfig = ''
        # Better prefix
        unbind C-b
        set-option -g prefix C-a
        bind-key C-a send-prefix
        
        # Split panes using | and -
        bind | split-window -h
        bind - split-window -v
        
        # Reload config
        bind r source-file ~/.tmux.conf
        
        # Fast pane switching
        bind -n M-Left select-pane -L
        bind -n M-Right select-pane -R
        bind -n M-Up select-pane -U
        bind -n M-Down select-pane -D
        
        # Enable mouse
        set -g mouse on
        
        # Don't rename windows automatically
        set-option -g allow-rename off
      '';
    };

    # Alacritty
    alacritty = {
      enable = true;
      
      settings = {
        window = {
          padding = {
            x = 10;
            y = 10;
          };
          opacity = 0.95;
        };
        
        font = {
          size = 12;
          
          normal = {
            family = "JetBrainsMono Nerd Font";
            style = "Regular";
          };
          
          bold = {
            family = "JetBrainsMono Nerd Font";
            style = "Bold";
          };
          
          italic = {
            family = "JetBrainsMono Nerd Font";
            style = "Italic";
          };
        };
        
        colors = {
          primary = {
            background = "#1d2021";
            foreground = "#ebdbb2";
          };
        };
      };
    };

    # VSCode
    vscode = {
      enable = true;
      extensions = with pkgs.vscode-extensions; [
        # Theme
        pkief.material-icon-theme
        
        # Language support
        ms-python.python
        ms-vscode.cpptools
        rust-lang.rust-analyzer
        golang.go
        
        # Tools
        ms-azuretools.vscode-docker
        ms-vscode-remote.remote-ssh
        eamodio.gitlens
        
        # Nix support
        bbenoist.nix
        jnoortheen.nix-ide
      ];
      
      userSettings = {
        "editor.fontSize" = 14;
        "editor.fontFamily" = "'JetBrainsMono Nerd Font', monospace";
        "editor.formatOnSave" = true;
        "editor.minimap.enabled" = false;
        "editor.rulers" = [ 80 120 ];
        "editor.wordWrap" = "on";
        
        "workbench.colorTheme" = "Gruvbox Dark Medium";
        "workbench.iconTheme" = "material-icon-theme";
        
        "terminal.integrated.fontSize" = 14;
        "terminal.integrated.fontFamily" = "'JetBrainsMono Nerd Font'";
      };
    };

    # Firefox
    firefox = {
      enable = true;
      
      profiles.default = {
        isDefault = true;
        
        settings = {
          "browser.startup.homepage" = "https://start.duckduckgo.com";
          "browser.search.defaultenginename" = "DuckDuckGo";
          "browser.search.order.1" = "DuckDuckGo";
          "privacy.trackingprotection.enabled" = true;
          "privacy.trackingprotection.socialtracking.enabled" = true;
        };
        
        # Extensions can be managed here
        # extensions = with pkgs.nur.repos.rycee.firefox-addons; [
        #   ublock-origin
        #   bitwarden
        #   privacy-badger
        # ];
      };
    };

    # Direnv
    direnv = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
      nix-direnv.enable = true;
    };
  };

  # Services
  services = {
    # GPG agent
    gpg-agent = {
      enable = true;
      enableSshSupport = true;
      pinentryPackage = pkgs.pinentry-gtk2;
    };
  };

  # GTK theme
  gtk = {
    enable = true;
    
    theme = {
      name = "Adwaita-dark";
      package = pkgs.gnome-themes-extra;
    };
    
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
    
    font = {
      name = "Ubuntu";
      size = 11;
    };
  };

  # Qt theme
  qt = {
    enable = true;
    platformTheme.name = "gtk";
    style.name = "adwaita-dark";
  };

  # XDG settings
  xdg = {
    enable = true;
    
    userDirs = {
      enable = true;
      createDirectories = true;
      
      desktop = "$HOME/Desktop";
      documents = "$HOME/Documents";
      download = "$HOME/Downloads";
      music = "$HOME/Music";
      pictures = "$HOME/Pictures";
      videos = "$HOME/Videos";
    };
    
    mimeApps = {
      enable = true;
      defaultApplications = {
        "text/html" = "brave-browser.desktop";
        "x-scheme-handler/http" = "brave-browser.desktop";
        "x-scheme-handler/https" = "brave-browser.desktop";
        "x-scheme-handler/about" = "brave-browser.desktop";
        "x-scheme-handler/unknown" = "brave-browser.desktop";
        "application/pdf" = "org.gnome.Evince.desktop";
        "image/png" = "org.gnome.eog.desktop";
        "image/jpeg" = "org.gnome.eog.desktop";
      };
    };
  };
}