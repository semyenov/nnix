{ config, pkgs, lib, inputs, ... }:

{
  # System administration packages
  home.packages = with pkgs; [
    # Monitoring
    btop htop iotop-c nethogs iftop bmon glances sysstat
    procs lsof strace ltrace
    
    # Network
    nmap tcpdump mtr traceroute dig whois netcat-gnu socat iperf3 bandwhich dog trippy
    
    # Security
    lynis aide chkrootkit age sops pass pwgen gnupg
    
    # Containers & Orchestration
    lazydocker dive kubectl k9s helm
    
    # Infrastructure
    terraform ansible vault
    
    # Cloud
    awscli2 google-cloud-sdk azure-cli
    
    # Backup
    restic borgbackup rclone rsync
    
    # File Management  
    lsd eza fd ripgrep bat dust duf broot ranger mc ncdu
    
    # Text Processing
    jq yq miller sd
    
    # Git
    gh gitlab lazygit delta difftastic tig
    
    # Database
    postgresql mariadb redis pgcli mycli
    
    # Debugging
    gdb valgrind hyperfine
    
    # Logs
    lnav multitail
    
    # Terminal
    tmux screen mosh asciinema expect
    
    # Hardware
    lshw hwinfo pciutils usbutils dmidecode smartmontools
    
    # Archives
    p7zip unrar zip unzip
    
    # Documentation  
    cheat  # Keep cheat for complex examples, tealdeer provides tldr
  ];
}