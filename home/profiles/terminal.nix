{
  config,
  pkgs,
  lib,
  inputs,
  ...
}: {
  home.packages = with pkgs; [
    # Shell Enhancements
    starship
    direnv
    atuin
    mcfly
    zellij
    navi
    vivid
    zoxide # Smarter cd command that learns your habits
    fzf # Command-line fuzzy finder
    skim # Rust alternative to fzf

    # Modern CLI Replacements
    lsd
    eza
    fd
    ripgrep
    bat
    dust
    duf
    procs
    btop
    bottom
    dog
    sd
    miller
    sad # CLI search and replace tool
    choose # Human-friendly alternative to cut
    hexyl # Command-line hex viewer

    # File Management
    broot
    xplr
    ranger
    mc
    ncdu
    dua
    tree
    yazi # Blazing fast terminal file manager with image preview
    ouch # Painless compression and decompression tool

    # Terminal Utilities
    tmux
    screen
    mosh
    asciinema
    expect
    gum # Fancy terminal UI components for shell scripts
    glow # Render markdown on the CLI with style
    slides # Terminal-based presentation tool

    # Data Processing
    jq
    yq
    visidata
    silicon
    tokei # Count lines of code quickly

    # Monitoring & Performance
    htop
    iotop-c
    nethogs
    iftop
    bmon
    glances
    sysstat
    lsof
    bandwhich
    trippy
    gping # Ping, but with a graph

    # Network Tools
    nmap
    tcpdump
    mtr
    traceroute
    dig
    whois
    netcat-gnu
    socat
    iperf3

    # System Information
    neofetch
    onefetch
    lshw
    hwinfo
    pciutils
    usbutils
    dmidecode
    smartmontools

    # Task Running & Development
    just # Command runner for project-specific tasks
    watchexec # Execute commands when files change
    entr # Run arbitrary commands when files change
    portal # Quick file transfers between computers

    # Security Tools
    age
    sops
    pass
    pwgen
    gnupg

    # Container Management
    kubectl
    k9s
    helm
    lazydocker
    dive
    oxker # Simple TUI to view & control docker containers

    # Infrastructure as Code
    terraform
    ansible
    vault

    # Cloud CLIs
    awscli2
    google-cloud-sdk
    azure-cli

    # Backup Tools
    restic
    borgbackup
    rclone
    rsync

    # Log Analysis
    lnav
    multitail

    # Archives
    p7zip
    unrar
    zip
    unzip

    # Fun
    cowsay
    lolcat
    cmatrix
  ];

  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      # Initialize Starship prompt
      starship init fish | source
    '';
  };

  home.sessionVariables = {
    EDITOR = "nvim";
    BROWSER = "brave";
    TERMINAL = "ghostty";
  };

  programs.direnv = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };
}
