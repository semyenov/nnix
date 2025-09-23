{
  config,
  pkgs,
  lib,
  inputs,
  ...
}: {
  home.packages = with pkgs; [
    # Monitoring
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

    # Security Tools (user-space; system-wide handled in profiles/security.nix)
    age
    sops
    pass
    pwgen
    gnupg

    # Container Management
    kubectl
    k9s
    helm

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
  ];
}
