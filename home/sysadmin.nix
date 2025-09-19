{ config, pkgs, lib, inputs, ... }:

let
  # Custom scripts for system administration
  adminScripts = pkgs.writeScriptBin "admin-toolkit" ''
    #!${pkgs.bash}/bin/bash
    case "$1" in
      audit)
        echo "Running system audit..."
        sudo lynis audit system
        ;;
      backup)
        echo "Starting backup..."
        restic backup --exclude-caches $HOME
        ;;
      update-all)
        echo "Updating system..."
        nix flake update
        sudo nixos-rebuild switch --flake .#nixos
        ;;
      *)
        echo "Usage: admin-toolkit {audit|backup|update-all}"
        ;;
    esac
  '';

  # Shell aliases optimized for system administration
  shellAliases = {
    # System monitoring
    top = "btop";
    htop = "btop";
    iotop = "sudo iotop-c";
    nethogs = "sudo nethogs";

    # Process management
    psg = "ps aux | rg";
    killall = "pkill";

    # Network
    ports = "sudo ss -tulpn";
    listening = "sudo lsof -i -P -n | rg LISTEN";
    connections = "sudo ss -tan";
    netstat = "ss";

    # System info
    sysinfo = "inxi -Fxz";
    meminfo = "free -h";
    diskinfo = "df -h";
    cpuinfo = "lscpu";

    # Logs
    logs = "journalctl -xe";
    logsf = "journalctl -xef";
    syslog = "sudo journalctl -u";
    userlog = "journalctl --user -xe";

    # Docker
    d = "docker";
    dc = "docker-compose";
    dps = "docker ps";
    dpsa = "docker ps -a";
    dimg = "docker images";
    dlog = "docker logs -f";
    dexec = "docker exec -it";
    dprune = "docker system prune -a";

    # Kubernetes
    k = "kubectl";
    kgp = "kubectl get pods";
    kgs = "kubectl get svc";
    kgd = "kubectl get deployment";
    kaf = "kubectl apply -f";
    kdel = "kubectl delete";
    klog = "kubectl logs -f";
    kexec = "kubectl exec -it";

    # Terraform
    tf = "terraform";
    tfi = "terraform init";
    tfp = "terraform plan";
    tfa = "terraform apply";
    tfd = "terraform destroy";

    # Ansible
    ap = "ansible-playbook";
    ai = "ansible-inventory";
    ag = "ansible-galaxy";

    # Security
    scan = "sudo nmap -sV";
    vuln = "sudo lynis audit system";
    checksum = "sha256sum";

    # File operations
    ll = "lsd -la";
    la = "lsd -la";
    lt = "lsd --tree";
    cat = "bat";
    grep = "rg";
    find = "fd";
    du = "dust";
    df = "duf";

    # Git
    g = "git";
    gs = "git status";
    gl = "git log --oneline --graph --decorate";
    gd = "git diff";

    # NixOS
    nrs = "sudo nixos-rebuild switch --flake .#nixos";
    nrt = "sudo nixos-rebuild test --flake .#nixos";
    nrb = "sudo nixos-rebuild build --flake .#nixos";
    nfu = "nix flake update";
    nfc = "nix flake check";
    ngc = "sudo nix-collect-garbage -d";
    nsg = "nix-store --gc";
    nso = "nix-store --optimise";
  };
in
{
  # Home configuration
  home = {
    username = "semyenov";
    homeDirectory = "/home/semyenov";
    stateVersion = "24.11";

    # Environment variables
    sessionVariables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
      BROWSER = "brave";
      TERMINAL = "alacritty";
      PAGER = "less -R";
      MANPAGER = "sh -c 'col -bx | bat -l man -p'";

      # Security
      GNUPGHOME = "$HOME/.gnupg";
      PASSWORD_STORE_DIR = "$HOME/.password-store";

      # Development
      DOCKER_BUILDKIT = "1";
      COMPOSE_DOCKER_CLI_BUILD = "1";
    };

    sessionPath = [
      "$HOME/.local/bin"
      "$HOME/bin"
      "$HOME/.cargo/bin"
      "$HOME/go/bin"
    ];

    # System administration packages
    packages = with pkgs; [
      # === System Monitoring & Performance ===
      btop           # Resource monitor
      htop           # Process viewer
      iotop-c        # I/O monitor
      nethogs        # Network bandwidth monitor
      iftop          # Network traffic monitor
      bmon           # Network bandwidth monitor
      nmon           # Performance monitor
      glances        # Cross-platform monitoring
      dstat          # Versatile resource statistics
      sysstat        # Performance monitoring tools

      # === Process Management ===
      procs          # Modern ps replacement
      pstree         # Process tree
      lsof           # List open files
      strace         # System call tracer
      ltrace         # Library call tracer

      # === Network Tools ===
      nmap           # Network scanner
      tcpdump        # Packet analyzer
      wireshark      # Network protocol analyzer
      mtr            # Network diagnostic
      traceroute     # Trace network path
      dig            # DNS lookup (part of dnsutils)
      whois          # Domain lookup
      netcat-gnu     # Network utility
      socat          # Multipurpose relay
      iperf3         # Network performance testing
      bandwhich      # Network utilization by process
      gping          # Ping with graph
      dog            # Modern DNS client
      trippy         # Network diagnostic tool

      # === Security & Auditing ===
      lynis          # Security auditing
      aide           # Intrusion detection
      chkrootkit     # Rootkit scanner
      fail2ban       # Intrusion prevention
      ufw            # Uncomplicated firewall
      age            # Modern encryption
      sops           # Secret management
      pass           # Password manager
      pwgen          # Password generator
      gnupg          # GPG encryption

      # === Container & Orchestration ===
      docker-compose # Docker compose
      lazydocker     # Docker TUI
      dive           # Docker image explorer
      kubectl        # Kubernetes CLI
      k9s            # Kubernetes TUI
      helm           # Kubernetes package manager
      kind           # Kubernetes in Docker
      minikube       # Local Kubernetes
      stern          # Multi-pod log tailing
      kubectx        # Kubernetes context switcher

      # === Infrastructure as Code ===
      terraform      # Infrastructure provisioning
      ansible        # Configuration management
      packer         # Image builder
      vault          # Secret management
      consul         # Service mesh

      # === Cloud Tools ===
      awscli2        # AWS CLI
      google-cloud-sdk # GCP CLI
      azure-cli      # Azure CLI
      doctl          # DigitalOcean CLI

      # === Backup & Recovery ===
      restic         # Backup program
      borgbackup     # Deduplicating backup
      rclone         # Cloud storage sync
      rsync          # File synchronization

      # === File Management ===
      lsd            # Modern ls
      eza            # Modern ls alternative
      fd             # Modern find
      ripgrep        # Fast grep
      bat            # Better cat
      dust           # Modern du
      duf            # Modern df
      broot          # Interactive tree
      ranger         # File manager
      mc             # Midnight Commander
      ncdu           # NCurses disk usage

      # === Text Processing ===
      jq             # JSON processor
      yq             # YAML processor
      xq             # XML processor
      miller         # CSV/JSON/etc processor
      sd             # Modern sed

      # === Development Tools ===
      gh             # GitHub CLI
      gitlab         # GitLab CLI
      lazygit        # Git TUI
      delta          # Git diff viewer
      difftastic     # Structural diff
      tig            # Git text interface

      # === Database Tools ===
      postgresql     # PostgreSQL client
      mysql          # MySQL client
      redis          # Redis client
      mongosh        # MongoDB shell
      pgcli          # Better PostgreSQL CLI
      mycli          # Better MySQL CLI

      # === Debugging & Profiling ===
      gdb            # GNU debugger
      valgrind       # Memory debugger
      perf-tools     # Performance analysis
      flamegraph     # Flame graph generator
      hyperfine      # Command-line benchmarking

      # === Log Management ===
      lnav           # Log file navigator
      multitail      # Multiple log viewer
      goaccess       # Real-time log analyzer

      # === System Utilities ===
      tmux           # Terminal multiplexer
      screen         # Terminal multiplexer
      mosh           # Mobile shell
      asciinema      # Terminal recorder
      ttyrec         # Terminal recorder
      expect         # Automation tool

      # === Hardware Info ===
      lshw           # Hardware lister
      hwinfo         # Hardware information
      pciutils       # PCI utilities
      usbutils       # USB utilities
      dmidecode      # DMI table decoder
      smartmontools  # SMART monitoring

      # === Archive Tools ===
      p7zip          # 7-Zip
      unrar          # RAR extractor
      zip            # ZIP utilities
      unzip          # ZIP extractor

      # === Documentation ===
      tldr           # Simplified man pages
      cheat          # Cheat sheets

      # === Custom Scripts ===
      adminScripts   # Custom admin toolkit
    ];
  };

  # Program configurations
  programs = {
    home-manager.enable = true;

    # Git with enhanced configuration
    git = {
      enable = true;
      userName = "Alexander Semyenov";
      userEmail = "semyenov@hotmail.com";

      delta = {
        enable = true;
        options = {
          navigate = true;
          line-numbers = true;
          side-by-side = true;
        };
      };

      extraConfig = {
        init.defaultBranch = "main";
        core = {
          editor = "nvim";
          pager = "delta";
        };
        pull.rebase = true;
        push.autoSetupRemote = true;
        merge.conflictstyle = "diff3";
        diff.algorithm = "histogram";

        # Signing
        commit.gpgsign = true;
        tag.gpgsign = true;

        # Performance
        pack.threads = "0";

        # Better aliases
        alias = {
          # Status & Info
          st = "status -sb";
          last = "log -1 HEAD --stat";

          # Branches
          br = "branch -vv";
          bra = "branch -vva";

          # Commits
          cm = "commit -m";
          amend = "commit --amend";

          # Diffs
          df = "diff";
          dfc = "diff --cached";

          # Logs
          lg = "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit";
          history = "log --pretty=format:'%h %ad | %s%d [%an]' --graph --date=short";

          # Stash
          sl = "stash list";
          sp = "stash pop";
          ss = "stash save";
        };
      };
    };

    # Enhanced Bash configuration
    bash = {
      enable = true;
      enableCompletion = true;
      inherit shellAliases;

      initExtra = ''
        # History configuration
        export HISTCONTROL=ignoreboth:erasedups
        export HISTSIZE=100000
        export HISTFILESIZE=200000
        shopt -s histappend
        shopt -s cmdhist

        # Better directory navigation
        shopt -s autocd
        shopt -s cdspell
        shopt -s dirspell

        # Globbing options
        shopt -s globstar
        shopt -s nocaseglob

        # Vi mode
        set -o vi

        # Custom functions

        # Extract any archive
        extract() {
          if [ -f "$1" ]; then
            case "$1" in
              *.tar.bz2)   tar xjf "$1"     ;;
              *.tar.gz)    tar xzf "$1"     ;;
              *.tar.xz)    tar xJf "$1"     ;;
              *.bz2)       bunzip2 "$1"     ;;
              *.rar)       unrar e "$1"     ;;
              *.gz)        gunzip "$1"      ;;
              *.tar)       tar xf "$1"      ;;
              *.tbz2)      tar xjf "$1"     ;;
              *.tgz)       tar xzf "$1"     ;;
              *.zip)       unzip "$1"       ;;
              *.Z)         uncompress "$1"  ;;
              *.7z)        7z x "$1"        ;;
              *)           echo "'$1' cannot be extracted" ;;
            esac
          else
            echo "'$1' is not a valid file"
          fi
        }

        # System information
        sysinfo() {
          echo "=== System Information ==="
          echo "Hostname: $(hostname)"
          echo "Kernel: $(uname -r)"
          echo "Uptime: $(uptime -p)"
          echo "Load: $(uptime | awk -F'load average:' '{print $2}')"
          echo "Memory: $(free -h | awk '/^Mem:/ {print $3 "/" $2}')"
          echo "Disk: $(df -h / | awk 'NR==2 {print $3 "/" $2 " (" $5 ")"}')"
          echo "CPU: $(lscpu | grep 'Model name' | cut -d':' -f2 | xargs)"
          echo "Cores: $(nproc)"
        }

        # Docker cleanup
        docker-cleanup() {
          docker container prune -f
          docker image prune -f
          docker network prune -f
          docker volume prune -f
        }

        # Find large files
        find-large() {
          fd -t f -x du -h {} \; | sort -rh | head -n "''${1:-10}"
        }

        # Monitor log file
        logmon() {
          if [ -z "$1" ]; then
            echo "Usage: logmon <logfile>"
            return 1
          fi
          tail -f "$1" | bat --paging=never -l log
        }

        # Check SSL certificate
        check-cert() {
          if [ -z "$1" ]; then
            echo "Usage: check-cert <domain>"
            return 1
          fi
          echo | openssl s_client -servername "$1" -connect "$1:443" 2>/dev/null | openssl x509 -noout -dates
        }

        # Port scan
        portscan() {
          if [ -z "$1" ]; then
            echo "Usage: portscan <host>"
            return 1
          fi
          nmap -sT -O "$1"
        }

        # Backup directory
        backup() {
          if [ -z "$1" ]; then
            echo "Usage: backup <directory>"
            return 1
          fi
          tar czf "''${1##*/}_$(date +%Y%m%d_%H%M%S).tar.gz" "$1"
        }
      '';
    };

    # Fish shell with admin focus
    fish = {
      enable = true;
      inherit shellAliases;

      interactiveShellInit = ''
        # Disable greeting
        set -g fish_greeting

        # Vi mode
        fish_vi_key_bindings

        # Better colors
        set -gx LS_COLORS (vivid generate molokai)

        # FZF configuration
        set -gx FZF_DEFAULT_COMMAND "fd --type f --hidden --follow --exclude .git"

        # Initialize tools
        zoxide init fish | source
        atuin init fish | source
      '';

      functions = {
        # System monitoring dashboard
        monitor = ''
          tmux new-session -d -s monitor
          tmux send-keys -t monitor "btop" Enter
          tmux split-window -t monitor -h
          tmux send-keys -t monitor "sudo nethogs" Enter
          tmux split-window -t monitor -v
          tmux send-keys -t monitor "watch -n 1 'ss -tan | head -20'" Enter
          tmux select-pane -t monitor -L
          tmux split-window -t monitor -v
          tmux send-keys -t monitor "journalctl -f" Enter
          tmux attach -t monitor
        '';

        # Docker stats dashboard
        docker-monitor = ''
          watch -n 1 'docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" && echo && docker stats --no-stream'
        '';

        # Network connections monitor
        netmon = ''
          sudo watch -n 1 'ss -tan | head -20 && echo && netstat -i'
        '';
      };
    };

    # Starship prompt
    starship = {
      enable = true;
      enableBashIntegration = true;
      enableFishIntegration = true;

      settings = {
        format = lib.concatStrings [
          "$username"
          "$hostname"
          "$directory"
          "$git_branch"
          "$git_status"
          "$kubernetes"
          "$docker_context"
          "$terraform"
          "$aws"
          "$gcloud"
          "$azure"
          "$nix_shell"
          "$cmd_duration"
          "$line_break"
          "$character"
        ];

        username = {
          show_always = true;
          format = "[$user]($style)@";
        };

        hostname = {
          ssh_only = false;
          format = "[$hostname]($style) ";
          style = "bold green";
        };

        directory = {
          truncation_length = 3;
          truncate_to_repo = false;
          style = "bold cyan";
        };

        git_branch = {
          symbol = " ";
          style = "bold purple";
        };

        kubernetes = {
          disabled = false;
          symbol = "☸ ";
          format = "[$symbol$context( \\($namespace\\))]($style) ";
          style = "cyan bold";
        };

        docker_context = {
          disabled = false;
          symbol = "🐋 ";
          format = "[$symbol$context]($style) ";
        };

        terraform = {
          disabled = false;
          symbol = "💠 ";
          format = "[$symbol$workspace]($style) ";
        };

        aws = {
          disabled = false;
          symbol = "☁️ ";
          format = "[$symbol($profile)(\\($region\\))]($style) ";
        };

        nix_shell = {
          disabled = false;
          symbol = "❄️ ";
          format = "[$symbol$state]($style) ";
        };

        cmd_duration = {
          min_time = 500;
          format = "took [$duration](bold yellow) ";
        };

        character = {
          success_symbol = "[➜](bold green)";
          error_symbol = "[✗](bold red)";
          vicmd_symbol = "[⮜](bold yellow)";
        };
      };
    };

    # Tmux for terminal multiplexing
    tmux = {
      enable = true;
      terminal = "screen-256color";
      historyLimit = 100000;
      keyMode = "vi";
      baseIndex = 1;

      plugins = with pkgs.tmuxPlugins; [
        sensible
        yank
        resurrect
        continuum
        cpu
        battery
      ];

      extraConfig = ''
        # Better prefix
        unbind C-b
        set-option -g prefix C-a
        bind-key C-a send-prefix

        # Split panes
        bind | split-window -h -c "#{pane_current_path}"
        bind - split-window -v -c "#{pane_current_path}"

        # Navigate panes
        bind h select-pane -L
        bind j select-pane -D
        bind k select-pane -U
        bind l select-pane -R

        # Resize panes
        bind -r H resize-pane -L 5
        bind -r J resize-pane -D 5
        bind -r K resize-pane -U 5
        bind -r L resize-pane -R 5

        # Mouse support
        set -g mouse on

        # Status bar
        set -g status-position bottom
        set -g status-bg colour234
        set -g status-fg colour137
        set -g status-left '#[fg=colour233,bg=colour245,bold] #S '
        set -g status-right '#[fg=colour233,bg=colour241,bold] %d/%m #[fg=colour233,bg=colour245,bold] %H:%M:%S '
        set -g status-right-length 50
        set -g status-left-length 20

        # Window status
        setw -g window-status-current-format '#[fg=colour81,bg=colour238,bold] #I:#W#F '
        setw -g window-status-format '#[fg=colour250,bg=colour235] #I:#W#F '

        # Pane borders
        set -g pane-border-style 'fg=colour238 bg=colour235'
        set -g pane-active-border-style 'bg=colour236 fg=colour51'

        # Reload config
        bind r source-file ~/.tmux.conf \; display "Config reloaded!"

        # Synchronize panes
        bind S setw synchronize-panes

        # Monitoring
        setw -g monitor-activity on
        set -g visual-activity on
      '';
    };

    # Neovim for text editing
    neovim = {
      enable = true;
      defaultEditor = true;
      viAlias = true;
      vimAlias = true;

      plugins = with pkgs.vimPlugins; [
        # Theme
        gruvbox-material

        # Core
        vim-sensible
        vim-surround
        vim-commentary
        vim-fugitive
        vim-repeat

        # File navigation
        telescope-nvim
        telescope-fzf-native-nvim
        nvim-tree-lua

        # LSP
        nvim-lspconfig
        null-ls-nvim
        trouble-nvim

        # Completion
        nvim-cmp
        cmp-nvim-lsp
        cmp-buffer
        cmp-path
        cmp-cmdline
        luasnip

        # Syntax
        nvim-treesitter.withAllGrammars
        nvim-treesitter-textobjects

        # UI
        lualine-nvim
        bufferline-nvim
        indent-blankline-nvim
        nvim-web-devicons

        # Git
        gitsigns-nvim
        diffview-nvim

        # Utils
        which-key-nvim
        toggleterm-nvim
        nvim-autopairs
        todo-comments-nvim

        # Debugging
        nvim-dap
        nvim-dap-ui
        nvim-dap-virtual-text
      ];

      extraConfig = ''
        " Leader key
        let mapleader = " "
        let maplocalleader = ","

        " Basic settings
        set number relativenumber
        set expandtab
        set tabstop=2
        set shiftwidth=2
        set smartindent
        set nowrap
        set noswapfile
        set nobackup
        set undofile
        set incsearch
        set hlsearch
        set ignorecase
        set smartcase
        set termguicolors
        set scrolloff=8
        set sidescrolloff=8
        set signcolumn=yes
        set updatetime=50
        set colorcolumn=80,120
        set clipboard=unnamedplus
        set mouse=a
        set splitbelow splitright

        " Theme
        set background=dark
        colorscheme gruvbox-material

        " Key mappings
        " File navigation
        nnoremap <leader>ff <cmd>Telescope find_files<cr>
        nnoremap <leader>fg <cmd>Telescope live_grep<cr>
        nnoremap <leader>fb <cmd>Telescope buffers<cr>
        nnoremap <leader>fh <cmd>Telescope help_tags<cr>
        nnoremap <leader>fr <cmd>Telescope oldfiles<cr>

        " File tree
        nnoremap <leader>e <cmd>NvimTreeToggle<cr>

        " Buffer navigation
        nnoremap <leader>bn :bnext<cr>
        nnoremap <leader>bp :bprevious<cr>
        nnoremap <leader>bd :bdelete<cr>

        " Window navigation
        nnoremap <C-h> <C-w>h
        nnoremap <C-j> <C-w>j
        nnoremap <C-k> <C-w>k
        nnoremap <C-l> <C-w>l

        " Terminal
        nnoremap <leader>tt <cmd>ToggleTerm<cr>
        nnoremap <leader>tg <cmd>lua require('toggleterm.terminal').Terminal:new({cmd = 'lazygit'}):toggle()<cr>

        " Git
        nnoremap <leader>gs <cmd>Git<cr>
        nnoremap <leader>gd <cmd>DiffviewOpen<cr>
        nnoremap <leader>gh <cmd>DiffviewFileHistory<cr>

        " Diagnostics
        nnoremap <leader>xx <cmd>TroubleToggle<cr>
        nnoremap <leader>xw <cmd>TroubleToggle workspace_diagnostics<cr>
        nnoremap <leader>xd <cmd>TroubleToggle document_diagnostics<cr>

        " Quick save/quit
        nnoremap <leader>w :w<cr>
        nnoremap <leader>q :q<cr>
        nnoremap <leader>Q :qa!<cr>

        " System clipboard
        vnoremap <leader>y "+y
        nnoremap <leader>Y "+yg_
        nnoremap <leader>y "+y
        nnoremap <leader>p "+p
        nnoremap <leader>P "+P
      '';
    };

    # SSH configuration
    ssh = {
      enable = true;
      compression = true;
      controlMaster = "auto";
      controlPersist = "10m";

      extraConfig = ''
        Host *
          ServerAliveInterval 60
          ServerAliveCountMax 3
          TCPKeepAlive yes
          AddKeysToAgent yes
      '';
    };

    # GPG
    gpg = {
      enable = true;
      settings = {
        no-greeting = true;
        no-emit-version = true;
        keyid-format = "0xlong";
        with-fingerprint = true;
      };
    };

    # Direnv for environment management
    direnv = {
      enable = true;
      enableBashIntegration = true;
      enableFishIntegration = true;
      nix-direnv.enable = true;
    };

    # FZF for fuzzy finding
    fzf = {
      enable = true;
      enableBashIntegration = true;
      enableFishIntegration = true;
      defaultOptions = [
        "--height 40%"
        "--border"
        "--inline-info"
        "--preview 'bat --style=numbers --color=always {}'"
      ];
    };

    # Zoxide for smart directory jumping
    zoxide = {
      enable = true;
      enableBashIntegration = true;
      enableFishIntegration = true;
    };

    # Atuin for shell history
    atuin = {
      enable = true;
      enableBashIntegration = true;
      enableFishIntegration = true;
      settings = {
        auto_sync = true;
        sync_frequency = "5m";
        search_mode = "fuzzy";
      };
    };

    # Bat configuration
    bat = {
      enable = true;
      config = {
        theme = "gruvbox-dark";
        pager = "less -FR";
      };
    };

    # Btop configuration
    btop = {
      enable = true;
      settings = {
        color_theme = "gruvbox_dark";
        theme_background = false;
        update_ms = 1000;
        proc_tree = true;
        proc_colors = true;
        proc_gradient = true;
      };
    };
  };

  # Services
  services = {
    # GPG Agent
    gpg-agent = {
      enable = true;
      enableSshSupport = true;
      defaultCacheTtl = 3600;
      maxCacheTtl = 7200;
      pinentryPackage = pkgs.pinentry-gtk2;
    };

    # Syncthing for file synchronization
    syncthing = {
      enable = false;  # Enable if needed
    };
  };

  # XDG configuration
  xdg = {
    enable = true;

    configFile = {
      # Htop configuration
      "htop/htoprc".text = ''
        fields=0 48 17 18 38 39 40 2 46 47 49 1
        sort_key=46
        sort_direction=1
        hide_threads=0
        hide_kernel_threads=1
        hide_userland_threads=0
        shadow_other_users=0
        show_program_path=0
        highlight_base_name=1
        highlight_megabytes=1
        highlight_threads=1
        tree_view=1
      '';

      # Custom scripts directory
      "scripts/admin-functions.sh".text = ''
        #!/bin/bash
        # Collection of admin helper functions

        # Service management
        service_status() {
          systemctl status "$1"
        }

        service_logs() {
          journalctl -u "$1" -f
        }

        # Network diagnostics
        net_connections() {
          ss -tulpn | grep LISTEN
        }

        # Disk usage analysis
        disk_usage() {
          df -h && echo && du -sh /* 2>/dev/null | sort -rh | head -20
        }
      '';
    };
  };
}