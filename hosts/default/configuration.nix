{ config, lib, pkgs, inputs, ... }:

{
  imports = [
    # Include hardware scan results
    ./hardware-configuration.nix
  ];

  # Boot loader configuration
  boot.loader = {
    systemd-boot.enable = true;
    systemd-boot.configurationLimit = 10;
    efi.canTouchEfiVariables = true;
    timeout = 3;
  };

  # Kernel parameters and modules
  boot.kernelParams = [ "quiet" "splash" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ ];

  # Networking
  networking = {
    hostName = "nixos"; # Define your hostname
    networkmanager.enable = true;
    
    # Firewall configuration
    firewall = {
      enable = true;
      allowedTCPPorts = [ ];
      allowedUDPPorts = [ ];
    };
  };

  # Time zone and locale
  time.timeZone = "UTC"; # Change to your timezone
  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings = {
      LC_ADDRESS = "en_US.UTF-8";
      LC_IDENTIFICATION = "en_US.UTF-8";
      LC_MEASUREMENT = "en_US.UTF-8";
      LC_MONETARY = "en_US.UTF-8";
      LC_NAME = "en_US.UTF-8";
      LC_NUMERIC = "en_US.UTF-8";
      LC_PAPER = "en_US.UTF-8";
      LC_TELEPHONE = "en_US.UTF-8";
      LC_TIME = "en_US.UTF-8";
    };
  };

  # Console configuration
  console = {
    font = "Lat2-Terminus16";
    useXkbConfig = true; # Use X11 keyboard layout for console
  };

  # Enable sound with PipeWire
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  # X11/Wayland configuration
  services.xserver = {
    enable = true;
    
    # Display manager
    displayManager.gdm = {
      enable = true;
      wayland = true;
    };
    
    # Desktop environment (GNOME as default, can be changed)
    desktopManager.gnome.enable = true;
    
    # Keyboard layout
    xkb = {
      layout = "us";
      variant = "";
      options = "caps:escape"; # Map Caps Lock to Escape
    };
  };

  # Enable CUPS for printing
  services.printing.enable = true;

  # Enable Bluetooth
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  # User accounts
  users.users.user = {
    isNormalUser = true;
    description = "Main User";
    extraGroups = [ 
      "wheel"         # Enable 'sudo'
      "networkmanager"
      "audio"
      "video"
      "docker"
      "libvirtd"
    ];
    shell = pkgs.fish; # Fish as default shell
    # initialPassword = "changeme"; # Remember to change this!
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Add overlays
  nixpkgs.overlays = [
    # Custom packages overlay
    (final: prev: {
      cursor-appimage = final.callPackage ../../packages/cursor-appimage.nix { };
      yandex-music = final.callPackage ../../packages/yandex-music.nix { };
    })

    # Unstable packages overlay
    (final: prev: {
      unstable = import inputs.nixpkgs-unstable {
        system = prev.system;
        config.allowUnfree = true;
      };
    })
  ];

  # System packages
  environment.systemPackages = with pkgs; ([
    # Core utilities
    vim
    neovim
    git
    wget
    curl
    htop
    btop
    tree
    unzip
    zip
    ripgrep
    fd
    bat
    eza
    zoxide
    fzf
    
    # Modern CLI replacements
    sd           # Modern sed replacement
    dust         # Modern du - disk usage with tree view
    duf          # Modern df - disk usage with better UI
    procs        # Modern ps replacement
    lsd          # Modern ls with icons and git integration
    choose       # Modern cut replacement
    tokei        # Fast code statistics
    bottom       # Another system monitor (lighter than btop)
    gping        # Ping with graph visualization
    dog          # Modern dig (DNS lookup)
    
    # Developer productivity tools
    gitui        # Blazing fast git TUI
    delta        # Beautiful git diffs
    xh           # Faster HTTPie alternative  
    curlie       # curl with HTTPie-like interface
    grex         # Generate regex from examples
    hyperfine    # Command benchmarking tool
    just         # Modern make alternative
    watchexec    # File watcher and command runner
    
    # System monitoring
    bandwhich    # Network usage by process
    
    # Data processing
    jq
    yq
    miller       # CSV/JSON/TSV swiss-army knife
    gron         # Make JSON greppable
    hexyl        # Modern hex viewer
    
    # Development tools
    gcc
    gnumake
    python3
    nodejs
    
    # System tools
    pciutils
    usbutils
    lshw
    dmidecode
    
    # Network tools
    nmap
    traceroute
    dig
    netcat
    
    # File management
    ranger
    ncdu
    
    # Terminal emulators
    alacritty
    kitty
    
    # Modern shells
    nushell      # Data-oriented shell
    
    # Network and development tools
    nekoray      # Qt-based GUI proxy configuration manager
  ] ++ [
    unstable.claude-code  # Claude Code CLI tool (from unstable)
  ]);

  # Environment variables
  environment.variables = {
    EDITOR = "nvim";
    BROWSER = "brave";
    TERMINAL = "alacritty";
  };

  # Shell aliases
  environment.shellAliases = {
    # Modern replacements for core utils
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
    htop = "btm";
    dig = "dog";
    
    # Git aliases
    g = "git";
    gg = "gitui";
    lg = "lazygit";
    
    # Quick commands
    j = "just";
    h = "hyperfine";
    
    # NixOS aliases
    rebuild = "sudo nixos-rebuild switch --flake .#nixos";
    update = "nix flake update";
    clean = "sudo nix-collect-garbage -d";
    generations = "sudo nix-env --list-generations --profile /nix/var/nix/profiles/system";
  };

  # Programs configuration
  programs = {
    bash.completion.enable = true;
    
    # Git configuration
    git = {
      enable = true;
      config = {
        init.defaultBranch = "main";
      };
    };
    
    # Enable GPG
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
    
    # Enable fish shell with plugins
    fish = {
      enable = true;
      vendor = {
        completions.enable = true;
        config.enable = true;
        functions.enable = true;
      };
    };
    
    
    # Enable zsh
    zsh = {
      enable = true;
      enableCompletion = true;
      syntaxHighlighting.enable = true;
      autosuggestions.enable = true;
    };
  };

  # Virtualisation
  virtualisation = {
    # Enable Docker
    docker = {
      enable = true;
      enableOnBoot = true;
    };
    
    # Enable libvirt for virtualization
    libvirtd = {
      enable = true;
      qemu = {
        package = pkgs.qemu_kvm;
        runAsRoot = false;
      };
    };
  };

  # Services
  services = {
    # Enable SSH daemon
    openssh = {
      enable = true;
      settings = {
        PermitRootLogin = "no";
        PasswordAuthentication = false;
      };
    };
    
    # Enable Flatpak
    flatpak.enable = true;
    
    
  };

  # Nix configuration
  nix = {
    package = pkgs.nixVersions.stable;
    
    settings = {
      # Enable flakes
      experimental-features = [ "nix-command" "flakes" ];
      
      # Optimizations
      auto-optimise-store = true;
      
      # Binary caches
      substituters = [
        "https://cache.nixos.org"
        "https://nix-community.cachix.org"
      ];
      
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
      
      # Allow specified users to use Nix
      trusted-users = [ "root" "@wheel" ];
    };
    
    # Garbage collection
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
  };

  # System state version (DO NOT CHANGE)
  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken.
  system.stateVersion = "24.11";
}
