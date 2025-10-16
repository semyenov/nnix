{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.sozdev.security;
in {
  options.sozdev.security = {
    enable =
      mkEnableOption "Enhanced security settings"
      // {
        default = true;
      };

    enableFirewall = mkOption {
      type = types.bool;
      default = true;
      description = "Enable and configure the firewall";
    };

    enableAppArmor = mkOption {
      type = types.bool;
      default = false;
      description = "Enable AppArmor for application sandboxing";
    };

    sshHardening = mkOption {
      type = types.bool;
      default = true;
      description = "Apply SSH hardening settings";
    };
  };

  config = mkIf cfg.enable {
    # GnuPG agent with pinentry
    programs.gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
      pinentryPackage = pkgs.pinentry-gnome3;
    };

    # Firewall configuration
    networking.firewall = mkIf cfg.enableFirewall {
      enable = true;
      logReversePathDrops = true;
      logRefusedConnections = true;
      logRefusedUnicastsOnly = true;
      allowPing = true;
    };

    # Security settings
    security = {
      sudo = {
        enable = true;
        wheelNeedsPassword = true;
        extraConfig = ''
          Defaults  timestamp_timeout=5
          Defaults  lecture=always
          Defaults  insults
        '';
      };

      protectKernelImage = true;
      forcePageTableIsolation = true;
      virtualisation.flushL1DataCache = "always";

      apparmor = mkIf cfg.enableAppArmor {
        enable = true;
        killUnconfinedConfinables = true;
      };

      polkit.enable = true;

      pam.loginLimits = [
        {
          domain = "@users";
          item = "core";
          type = "hard";
          value = "0";
        }
        {
          domain = "*";
          item = "nofile";
          type = "soft";
          value = "4096";
        }
      ];
    };

    # Boot security
    boot = {
      kernel.sysctl = {
        # Network security
        "net.ipv4.conf.all.accept_redirects" = 0;
        "net.ipv4.conf.default.accept_redirects" = 0;
        "net.ipv6.conf.all.accept_redirects" = 0;
        "net.ipv6.conf.default.accept_redirects" = 0;
        "net.ipv4.conf.all.send_redirects" = 0;
        "net.ipv4.conf.default.send_redirects" = 0;
        "net.ipv4.tcp_syncookies" = 1;

        # Kernel hardening
        "kernel.printk" = "3 3 3 3";
        "kernel.yama.ptrace_scope" = 1;
        "kernel.randomize_va_space" = 2;
        # io_uring control (0=enabled, 1=disabled for unprivileged, 2=fully disabled)
        # Enabled for applications like Ghostty that require io_uring for async I/O
        # Note: On some hardened kernels, this parameter may be locked at boot
        "kernel.io_uring_disabled" = 0;
        "net.ipv4.tcp_rfc1337" = 1;
        "net.ipv4.tcp_max_syn_backlog" = 4096;
        "net.ipv4.tcp_synack_retries" = 3;
        "net.ipv4.conf.all.accept_source_route" = 0;
        "net.ipv6.conf.all.accept_source_route" = 0;
        "net.ipv4.conf.all.log_martians" = 1;
        "net.ipv4.conf.default.log_martians" = 1;
        "net.ipv4.icmp_echo_ignore_broadcasts" = 1;
        "net.ipv4.icmp_ignore_bogus_error_responses" = 1;
        "fs.suid_dumpable" = 0;
        "kernel.kptr_restrict" = 2;
        "kernel.dmesg_restrict" = 1;
        "kernel.kexec_load_disabled" = 1;
        "kernel.unprivileged_bpf_disabled" = 1;
        "net.core.bpf_jit_harden" = 2;
        "vm.unprivileged_userfaultfd" = 0;
      };

      blacklistedKernelModules = [
        "dccp"
        "sctp"
        "rds"
        "tipc"
        # "bluetooth" # Commented out to allow Bluetooth support
        # "usb-storage" # Commented out to allow USB storage
      ];
    };

    # SSH hardening
    services.openssh = mkIf cfg.sshHardening {
      enable = true;

      settings = {
        PermitRootLogin = "no";
        PasswordAuthentication = false;
        PubkeyAuthentication = true;
        AuthenticationMethods = "publickey";
        StrictModes = true;
        IgnoreRhosts = true;
        HostbasedAuthentication = false;
        PermitEmptyPasswords = false;
        X11Forwarding = false;
        AllowAgentForwarding = false;
        AllowTcpForwarding = false;
        ClientAliveInterval = 300;
        ClientAliveCountMax = 2;
        LoginGraceTime = 60;

        Ciphers = [
          "chacha20-poly1305@openssh.com"
          "aes256-gcm@openssh.com"
          "aes128-gcm@openssh.com"
        ];

        KexAlgorithms = [
          "curve25519-sha256"
          "curve25519-sha256@libssh.org"
        ];

        Macs = [
          "hmac-sha2-512-etm@openssh.com"
          "hmac-sha2-256-etm@openssh.com"
        ];
      };

      extraConfig = ''
        Banner /etc/ssh/banner
      '';
    };

    # Create SSH banner
    environment.etc."ssh/banner".text = ''
      ##############################################################
      #                     AUTHORIZED ACCESS ONLY                #
      #                                                           #
      # Unauthorized access to this system is strictly prohibited #
      # All access attempts are logged and monitored             #
      ##############################################################
    '';

    # Audit daemon
    security.auditd.enable = true;
    security.audit = {
      enable = true;
      rules = [
        "-w /etc/passwd -p wa -k passwd_changes"
        "-w /etc/shadow -p wa -k shadow_changes"
        "-w /etc/group -p wa -k group_changes"
      ];
    };

    # Fail2ban for brute force protection
    services.fail2ban = {
      enable = true;
      maxretry = 3;
      bantime = "1h";
      bantime-increment.enable = true;

      jails = {
        sshd-custom = ''
          enabled = true
          port = 22
          filter = sshd
          maxretry = 3
          findtime = 600
          bantime = 3600
          backend = systemd
        '';
      };
    };

    # Security packages
    environment.systemPackages = with pkgs; [
      aide
      chkrootkit
      lynis
      iptables
      nftables
      pwgen
      pass
    ];

    services.usbguard.enable = lib.mkDefault false;
  };
}
