{ config, pkgs, lib, inputs, ... }:

{
  # Pull key parts of your rich sysadmin.nix here incrementally
  home.packages = with pkgs; [
    btop htop iotop-c nethogs iftop bmon nmon glances dool sysstat
    procs pstree lsof strace ltrace
    nmap tcpdump wireshark mtr traceroute dig whois netcat-gnu socat iperf3 bandwhich dog trippy
    lynis aide chkrootkit fail2ban age sops pass pwgen gnupg
    docker-compose lazydocker dive kubectl k9s helm kind minikube stern kubectx
    terraform ansible packer vault consul
    awscli2 google-cloud-sdk azure-cli doctl
    restic borgbackup rclone rsync
    lsd eza fd ripgrep bat dust duf broot ranger mc ncdu
    jq yq miller sd
    gh gitlab lazygit delta difftastic tig
    postgresql mariadb redis mongosh pgcli mycli
    gdb valgrind perf-tools flamegraph hyperfine
    lnav multitail goaccess
    tmux screen mosh asciinema ovh-ttyrec expect
    lshw hwinfo pciutils usbutils dmidecode smartmontools
    p7zip unrar zip unzip
    tldr cheat
  ];
}
