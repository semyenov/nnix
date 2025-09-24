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

    # File Management
    broot
    xplr
    ranger
    mc
    ncdu
    dua

    # Terminal Utilities
    tmux
    screen
    mosh
    asciinema
    expect

    # Data Processing
    jq
    yq
    visidata
    silicon

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