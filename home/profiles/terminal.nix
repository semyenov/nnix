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

  # Configure Starship for a double-line prompt
  programs.starship = {
    enable = true;
    enableFishIntegration = true;
    settings = {
      format = "$username$hostname$directory$git_branch$git_state$git_status$cmd_duration\n$character";
      username = {
        style_user = "blue bold";
        style_root = "red bold";
        format = "[$user]($style) ";
        show_always = true;
      };
      hostname = {
        ssh_only = false;
        format = "[@$hostname](blue bold) ";
        trim_at = ".local";
        style = "green bold";
      };
      directory = {
        style = "cyan bold";
        truncate_to_repo = false;
        truncation_length = 3;
        truncation_symbol = "…/";
      };
      character = {
        success_symbol = "[❯](green bold)";
        error_symbol = "[✖](red bold)";
      };
      git_branch = {
        format = "[$symbol$branch](purple bold) ";
        symbol = " ";
      };
    };
  };

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
