{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.sozdev.optimizations;
in {
  options.sozdev.optimizations = {
    enable =
      mkEnableOption "System performance optimizations"
      // {
        default = false;
      };
  };

  config = mkIf cfg.enable {
    # System performance optimizations

    zramSwap = {
      enable = true;
      memoryPercent = 25; # Use 25% of RAM for zram (about 16GB on your 64GB system)
      algorithm = "zstd";
    };

    # Boot optimizations
    boot = {
      # Kernel parameters for better desktop responsiveness
      kernelParams = [
        "quiet"
        "splash"
        "mitigations=off" # Better performance, slightly less secure
        "nowatchdog"
        "loglevel=3"
        "modprobe.blacklist=sp5100_tco" # Disable watchdog timer
        "systemd.unified_cgroup_hierarchy=1"
        "transparent_hugepage=madvise"
      ];

      # Use kernel 6.16 for NVIDIA driver compatibility
      # Note: linuxPackages_latest (6.17) breaks NVIDIA production drivers
      kernelPackages = pkgs.linuxPackages_6_12_hardened;

      # Reduce kernel log verbosity
      consoleLogLevel = 3;

      # Plymouth for pretty boot (optional, comment out if you prefer text boot)
      plymouth = {
        enable = true;
        theme = "breeze";
      };

      # Tmpfs for /tmp with proper options
      tmp = {
        useTmpfs = true;
        tmpfsSize = "8G";
      };

      # Enable kernel same-page merging for memory deduplication
      kernel.sysctl = {
        "kernel.sysrq" = 1; # Enable SysRq for emergencies
        "vm.swappiness" = 10; # Prefer RAM over swap
        "vm.vfs_cache_pressure" = 50; # Balance between reclaiming dentries/inodes and pagecache
        "vm.dirty_background_ratio" = 5; # Start writing to disk when 5% dirty
        "vm.dirty_ratio" = 10; # Force synchronous I/O when 10% dirty

        # Network optimizations
        "net.core.default_qdisc" = "cake";
        "net.ipv4.tcp_congestion_control" = "cubic"; # Changed from bbr (not available)
        "net.ipv4.tcp_fastopen" = 3;
        "net.ipv4.tcp_mtu_probing" = 1;

        # Desktop interactivity - removed deprecated sched_* parameters
        # These were removed in newer kernel versions:
        # kernel.sched_latency_ns
        # kernel.sched_min_granularity_ns
        # kernel.sched_wakeup_granularity_ns
      };
    };

    # Systemd optimizations
    systemd = {
      # Disable services that slow boot
      services = {
        NetworkManager-wait-online.enable = false;
        systemd-networkd-wait-online.enable = false;
      };

      # Faster shutdown
      extraConfig = ''
        DefaultTimeoutStartSec=10s
        DefaultTimeoutStopSec=10s
        DefaultDeviceTimeoutSec=10s
      '';

      # OOM killer configuration with earlyoom as backup
      oomd = {
        enable = true;
        enableRootSlice = true;
        enableSystemSlice = true;
        enableUserSlices = true;
      };

      # Tmpfiles cleanup rules
      tmpfiles.rules = [
        "d /tmp 1777 root root 7d" # Clean /tmp after 7 days
        "d /var/tmp 1777 root root 30d" # Clean /var/tmp after 30 days
        "e /var/cache - - - 30d" # Clean cache after 30 days
        "e /var/log - - - 90d" # Clean old logs after 90 days
      ];
    };

    # EarlyOOM - more aggressive than systemd-oomd
    services.earlyoom = {
      enable = true;
      freeMemThreshold = 5; # Kill when <5% RAM free
      freeSwapThreshold = 10; # Kill when <10% swap free
      enableNotifications = true;
    };

    # I/O scheduler optimizations
    services.udev.extraRules = ''
      # NVMe drives don't expose scheduler attribute in modern kernels - skip
      # Use 'mq-deadline' for SATA SSDs
      ACTION=="add|change", KERNEL=="sd[a-z]", ATTR{queue/rotational}=="0", ATTR{queue/scheduler}="mq-deadline"
      # Use 'bfq' for HDDs
      ACTION=="add|change", KERNEL=="sd[a-z]", ATTR{queue/rotational}=="1", ATTR{queue/scheduler}="bfq"
    '';

    # Enable thermald for Intel CPU thermal management
    services.thermald.enable = lib.mkDefault true;

    # Power management
    powerManagement = {
      enable = true;
      cpuFreqGovernor = lib.mkDefault "ondemand";
    };

    # Disable unnecessary services for desktop
    services.udisks2.enable = lib.mkDefault true; # Keep for automounting
    services.fstrim.enable = true; # Weekly TRIM for SSDs

    # Fix mDNS warnings
    services.avahi = {
      enable = true;
      nssmdns4 = true;
      nssmdns6 = true;
      publish = {
        enable = true;
        addresses = true;
        workstation = true;
      };
    };
  };
}
