{pkgs, ...}: {
  # Terminal emulators previously in system module
  programs.alacritty.enable = true;
  programs.kitty.enable = true;
  # Ghostty is a package; ensure available in PATH
  home.packages =
    (with pkgs; [ghostty])
    ++ (
      # Terminal-related user packages
      with pkgs; [
        # Shell enhancements (starship removed - using Tide theme via omf.nix)
        atuin
        mcfly
        zellij
        navi
        vivid
        zoxide
        fzf
        skim
        go-task

        # Modern CLI replacements
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
        sad
        choose
        hexyl

        # File management
        broot
        xplr
        ranger
        mc
        ncdu
        dua
        tree
        yazi
        ouch

        # Terminal utilities
        tmux
        screen
        mosh
        asciinema
        expect
        gum
        glow
        slides

        # Data processing
        jq
        yq
        visidata
        silicon
        tokei

        # Monitoring & performance
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
        gping

        # Network tools
        nmap
        tcpdump
        mtr
        traceroute
        dig
        whois
        netcat-gnu
        socat
        iperf3

        # System information
        neofetch
        onefetch
        lshw
        hwinfo
        pciutils
        usbutils
        dmidecode
        smartmontools

        # Task running & development
        just
        watchexec
        entr
        portal

        # Security tools
        age
        sops
        pass
        pwgen
        gnupg

        # Container management
        kubectl
        k9s
        helm
        lazydocker
        dive
        oxker

        # Infrastructure as code
        terraform
        ansible
        vault

        # Cloud CLIs
        awscli2
        google-cloud-sdk
        azure-cli

        # Backup tools
        restic
        borgbackup
        rclone
        rsync

        # Log analysis
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
      ]
    );
}
