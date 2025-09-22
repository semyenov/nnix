{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.system.security;
in
{
  options.modules.system.security = {
    enable = mkEnableOption "Enhanced security settings";
    
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
    # Firewall configuration
    networking.firewall = mkIf cfg.enableFirewall {
      enable = true;
      # Log dropped/refused packets
      logReversePathDrops = true;
      logRefusedConnections = true;
      logRefusedUnicastsOnly = true;
      # Allow ICMP for diagnostics unless policy forbids
      allowPing = true;
      
      # Example port configurations
      # allowedTCPPorts = [ 22 80 443 ];
      # allowedUDPPorts = [ ];
    };

    # Security settings
    security = {
      # Enable sudo with insults (fun but optional)
      sudo = {
        enable = true;
        wheelNeedsPassword = true;
        extraConfig = ''
          # Require password for sudo
          Defaults  timestamp_timeout=5
          Defaults  lecture=always
          Defaults  insults
        '';
      };
      
      # Kernel hardening
      protectKernelImage = true;
      forcePageTableIsolation = true;
      virtualisation.flushL1DataCache = "always";
      
      # AppArmor
      apparmor = mkIf cfg.enableAppArmor {
        enable = true;
        killUnconfinedConfinables = true;
      };
      
      # Polkit
      polkit.enable = true;
      
      # PAM configuration
      pam = {
        # Login settings
        loginLimits = [
          {
            domain = "@users";
            item = "core";
            type = "hard";
            value = "0";  # Disable core dumps for users
          }
          {
            domain = "*";
            item = "nofile";
            type = "soft";
            value = "4096";  # Limit open files
          }
        ];
      };
    };

    # Boot security
    boot = {
      # Kernel security parameters - merged with additional hardening below
      kernel.sysctl = {
        # Network security
        "net.ipv4.conf.all.accept_redirects" = 0;
        "net.ipv4.conf.default.accept_redirects" = 0;
        "net.ipv6.conf.all.accept_redirects" = 0;
        "net.ipv6.conf.default.accept_redirects" = 0;

        "net.ipv4.conf.all.send_redirects" = 0;
        "net.ipv4.conf.default.send_redirects" = 0;

        # Enable SYN flood protection
        "net.ipv4.tcp_syncookies" = 1;

        # IP forwarding: leave default (0). Docker profile may override to 1.

        # Kernel hardening
        "kernel.printk" = "3 3 3 3";
        "kernel.yama.ptrace_scope" = 1;


        # Additional hardening when enabled
        # Disable unprivileged user namespaces (breaks some sandboxing but more secure)
        "kernel.unprivileged_userns_clone" = 0;

        # Increase ASLR effectiveness
        "kernel.randomize_va_space" = 2;

        # Protect against time-wait assassination
        "net.ipv4.tcp_rfc1337" = 1;

        # Protection against SYN flood attacks
        "net.ipv4.tcp_max_syn_backlog" = 4096;
        "net.ipv4.tcp_synack_retries" = 3;

        # Disable source packet routing
        "net.ipv4.conf.all.accept_source_route" = 0;
        "net.ipv6.conf.all.accept_source_route" = 0;

        # Log Martians (packets with impossible addresses)
        "net.ipv4.conf.all.log_martians" = 1;
        "net.ipv4.conf.default.log_martians" = 1;

        # Ignore bogus ICMP errors
        "net.ipv4.icmp_echo_ignore_broadcasts" = 1;
        "net.ipv4.icmp_ignore_bogus_error_responses" = 1;

        # Restrict core dumps
        "fs.suid_dumpable" = 0;

        # Hide kernel symbols in /proc/kallsyms
        "kernel.kptr_restrict" = 2;

        # Restrict dmesg to root
        "kernel.dmesg_restrict" = 1;

        # Disable kexec (prevent replacing kernel)
        "kernel.kexec_load_disabled" = 1;

        # BPF hardening
        "kernel.unprivileged_bpf_disabled" = 1;
        "net.core.bpf_jit_harden" = 2;

        # Restrict userfaultfd to CAP_SYS_PTRACE
        "vm.unprivileged_userfaultfd" = 0;
      };
      
      # Blacklist unnecessary kernel modules
      blacklistedKernelModules = [
        "dccp"
        "sctp"
        "rds"
        "tipc"
        "bluetooth"
        "usb-storage"  # If not needed
      ];
    };

    # SSH hardening
    services.openssh = mkIf cfg.sshHardening {
      enable = true;
      
      settings = {
        # Authentication
        PermitRootLogin = "no";
        PasswordAuthentication = false;
        PubkeyAuthentication = true;
        AuthenticationMethods = "publickey";
        
        # Security
        StrictModes = true;
        IgnoreRhosts = true;
        HostbasedAuthentication = false;
        PermitEmptyPasswords = false;
        
        # Forwarding
        X11Forwarding = false;
        AllowAgentForwarding = false;
        AllowTcpForwarding = false;
        
        # Timeouts
        ClientAliveInterval = 300;
        ClientAliveCountMax = 2;
        LoginGraceTime = 60;
        
        # Users can be constrained per-host via profiles or host config
        
        # Cryptography
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
      
      # SSH banner
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
        # SSH jail with custom configuration
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

    # Additional packages for security
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