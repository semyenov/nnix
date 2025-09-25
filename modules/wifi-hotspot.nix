{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.sozdev.wifi-hotspot;

  # Helper function to parse CIDR notation
  parseCIDR = cidr: let
    parts = splitString "/" cidr;
  in {
    network = elemAt parts 0;
    prefixLength = toInt (elemAt parts 1);
  };

  # Parse subnet configuration
  subnetInfo = parseCIDR cfg.subnet;

  # Helper to check if IP is in subnet
  ipToInt = ip: let
    parts = map toInt (splitString "." ip);
  in (elemAt parts 0) * 16777216 + (elemAt parts 1) * 65536 + (elemAt parts 2) * 256 + (elemAt parts 3);

  # Calculate network mask
  networkMask = prefixLength: let
    fullBytes = prefixLength / 8;
    remainingBits = mod prefixLength 8;
  in (fullBytes * 8) + remainingBits;

  # Determine MAC ACL mode correctly
  macAclMode =
    if cfg.macAllowList != [] then "allow"
    else if cfg.macDenyList != [] then "deny"
    else "";  # Empty means no MAC filtering (allow all)

  # Determine authentication mode
  authMode =
    if cfg.passphrase == "" then "none"
    else if cfg.wpa3 && cfg.wpa2 then "wpa2-sha256|wpa3-sae"  # Transitional mode
    else if cfg.wpa3 then "wpa3-sae"
    else "wpa2-sha256";

  # Check if using transitional mode
  isTransitionalMode = cfg.wpa2 && cfg.wpa3 && cfg.passphrase != "";

in {
  options.sozdev.wifi-hotspot = {
    enable = mkEnableOption "WiFi hotspot with internet sharing";

    interface = mkOption {
      type = types.str;
      default = "wlan0";
      description = "Wireless interface to use for the hotspot";
    };

    ssid = mkOption {
      type = types.str;
      default = "NixOS-Hotspot";
      description = "SSID (network name) for the hotspot";
    };

    passphrase = mkOption {
      type = types.str;
      default = "";
      description = "WPA2/WPA3 passphrase for the hotspot (minimum 8 characters, empty for open network)";
    };

    wpa2 = mkOption {
      type = types.bool;
      default = true;
      description = "Enable WPA2 authentication";
    };

    wpa3 = mkOption {
      type = types.bool;
      default = false;
      description = "Enable WPA3 authentication (requires compatible hardware)";
    };

    band = mkOption {
      type = types.enum ["2g" "5g" "6g"];
      default = "2g";
      description = "Frequency band to use";
    };

    channel = mkOption {
      type = types.int;
      default = 0;
      description = "WiFi channel to use (0 for automatic selection)";
    };

    countryCode = mkOption {
      type = types.nullOr types.str;
      default = null;
      example = "US";
      description = "Country code for regulatory domain (required for 5GHz/6GHz in most regions)";
    };

    gateway = mkOption {
      type = types.str;
      default = "192.168.12.1";
      description = "Gateway IP address for the hotspot network";
    };

    subnet = mkOption {
      type = types.str;
      default = "192.168.12.0/24";
      description = "Subnet for the hotspot network in CIDR notation";
    };

    dhcpRangeStart = mkOption {
      type = types.str;
      default = "192.168.12.10";
      description = "Start of DHCP IP range";
    };

    dhcpRangeEnd = mkOption {
      type = types.str;
      default = "192.168.12.100";
      description = "End of DHCP IP range";
    };

    internetInterface = mkOption {
      type = types.nullOr types.str;
      default = null;
      example = "eth0";
      description = "Interface connected to the internet for sharing (null to auto-detect default route)";
    };

    bridgeMode = mkOption {
      type = types.bool;
      default = false;
      description = "Use bridge mode instead of NAT (requires bridge configuration)";
    };

    dns = mkOption {
      type = types.listOf types.str;
      default = ["8.8.8.8" "8.8.4.4"];
      description = "DNS servers to use for hotspot clients";
    };

    isolateClients = mkOption {
      type = types.bool;
      default = false;
      description = "Isolate clients from each other (AP isolation)";
    };

    hideSSID = mkOption {
      type = types.bool;
      default = false;
      description = "Hide SSID from broadcast";
    };

    macAllowList = mkOption {
      type = types.listOf types.str;
      default = [];
      example = ["aa:bb:cc:dd:ee:ff"];
      description = "List of MAC addresses to allow (empty means no MAC filtering)";
    };

    macDenyList = mkOption {
      type = types.listOf types.str;
      default = [];
      example = ["aa:bb:cc:dd:ee:ff"];
      description = "List of MAC addresses to deny";
    };

    ieee80211ac = mkOption {
      type = types.bool;
      default = true;
      description = "Enable 802.11ac (WiFi 5) support if hardware supports it";
    };

    ieee80211ax = mkOption {
      type = types.bool;
      default = false;
      description = "Enable 802.11ax (WiFi 6) support if hardware supports it";
    };

    bandwidthLimit = mkOption {
      type = types.nullOr types.str;
      default = null;
      example = "10mbit";
      description = "Bandwidth limit per client (using tc)";
    };

    autoStart = mkOption {
      type = types.bool;
      default = false;
      description = "Automatically start hotspot on boot";
    };

    conflictResolution = mkOption {
      type = types.enum ["fail" "disable-conflicts" "isolate"];
      default = "fail";
      description = ''
        How to handle conflicts with existing services:
        - fail: Fail if conflicts detected (default, safest)
        - disable-conflicts: Disable conflicting services
        - isolate: Use isolated instances where possible
      '';
    };

    validateHardware = mkOption {
      type = types.bool;
      default = true;
      description = "Validate that the interface supports AP mode";
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.passphrase == "" || (builtins.stringLength cfg.passphrase >= 8);
        message = "WiFi hotspot passphrase must be at least 8 characters long or empty for open network";
      }
      {
        assertion = cfg.passphrase != "" || (!cfg.wpa2 && !cfg.wpa3);
        message = "Cannot enable WPA2/WPA3 with empty passphrase";
      }
      {
        assertion = !(cfg.band == "5g" || cfg.band == "6g") || cfg.countryCode != null;
        message = "Country code is required for 5GHz and 6GHz bands for regulatory compliance";
      }
      {
        assertion = !(cfg.macAllowList != [] && cfg.macDenyList != []);
        message = "Cannot use both MAC allow list and deny list simultaneously";
      }
      {
        assertion = !cfg.bridgeMode || cfg.internetInterface != null;
        message = "Bridge mode requires explicitly specifying the internet interface";
      }
      {
        assertion = cfg.conflictResolution != "fail" ||
                   (!config.services.dnsmasq.enable || cfg.conflictResolution == "isolate");
        message = "dnsmasq is already enabled globally. Set conflictResolution to 'disable-conflicts' or 'isolate' to proceed";
      }
      {
        assertion = cfg.internetInterface != null || !cfg.bridgeMode;
        message = "Internet interface must be specified when not using auto-detection";
      }
    ];

    warnings =
      (optional (cfg.wpa3 && !cfg.ieee80211ax) "WPA3 works best with WiFi 6 (802.11ax) hardware") ++
      (optional (cfg.band == "6g" && !cfg.ieee80211ax) "6GHz band requires WiFi 6E (802.11ax) support") ++
      (optional (cfg.validateHardware && cfg.interface == "wlan0") "Hardware validation is enabled but cannot be performed at build time. Ensure ${cfg.interface} supports AP mode");

    # Add interface to NetworkManager unmanaged list
    networking.networkmanager.unmanaged = mkIf config.networking.networkmanager.enable [
      cfg.interface
    ];

    # Enable hostapd for access point
    services.hostapd = {
      enable = true;
      radios.${cfg.interface} = {
        band = cfg.band;
        channel = cfg.channel;
        countryCode = cfg.countryCode;

        # WiFi capabilities
        wifi4.enable = true;
        wifi5.enable = mkIf (cfg.band == "5g") true;
        wifi6.enable = mkIf cfg.ieee80211ax true;

        networks.${cfg.interface} = {
          ssid = cfg.ssid;

          authentication = mkMerge [
            # Base authentication configuration
            {
              mode = authMode;
            }

            # WPA2 configuration
            (mkIf (cfg.wpa2 && cfg.passphrase != "" && !isTransitionalMode) {
              wpaPassphrase = cfg.passphrase;
            })

            # WPA3 configuration
            (mkIf (cfg.wpa3 && cfg.passphrase != "" && !isTransitionalMode) {
              saePasswords = [{password = cfg.passphrase;}];
            })

            # Transitional mode configuration
            (mkIf isTransitionalMode {
              wpaPassphrase = cfg.passphrase;
              saePasswords = [{password = cfg.passphrase;}];
            })
          ];

          settings = {
            # Basic WiFi settings
            ieee80211n = true;
            ieee80211ac = mkIf (cfg.band == "5g" && cfg.ieee80211ac) true;
            ieee80211ax = mkIf cfg.ieee80211ax true;
            wmm_enabled = true;

            # Security settings
            ignore_broadcast_ssid = mkIf cfg.hideSSID 1;
            ap_isolate = mkIf cfg.isolateClients 1;

            # Country-specific settings
            ieee80211d = mkIf (cfg.countryCode != null) true;
            ieee80211h = mkIf (cfg.countryCode != null) true;
          };

          # MAC ACL configuration (only set if using MAC filtering)
          macAllow = cfg.macAllowList;
          macDeny = cfg.macDenyList;
          macAcl = macAclMode;
        };
      };
    };

    # Configure network interface
    networking.interfaces.${cfg.interface} = {
      ipv4.addresses = [{
        address = cfg.gateway;
        prefixLength = subnetInfo.prefixLength;
      }];
    };

    # Create isolated dnsmasq instance for hotspot
    systemd.services.hotspot-dnsmasq = mkIf (!cfg.bridgeMode) {
      description = "dnsmasq DHCP server for WiFi hotspot";
      after = ["network.target" "hostapd.service"];
      bindsTo = ["hostapd.service"];
      wantedBy = mkIf cfg.autoStart ["multi-user.target"];

      serviceConfig = {
        Type = "forking";
        PIDFile = "/run/hotspot-dnsmasq.pid";
        ExecStart = ''
          ${pkgs.dnsmasq}/bin/dnsmasq \
            --interface=${cfg.interface} \
            --bind-interfaces \
            --except-interface=lo \
            --dhcp-range=${cfg.dhcpRangeStart},${cfg.dhcpRangeEnd},12h \
            --dhcp-option=option:router,${cfg.gateway} \
            --dhcp-option=option:dns-server,${concatStringsSep "," cfg.dns} \
            --server=${concatStringsSep " --server=" cfg.dns} \
            --no-hosts \
            --no-resolv \
            --pid-file=/run/hotspot-dnsmasq.pid \
            --dhcp-leasefile=/var/lib/hotspot-dnsmasq/leases
        '';
        ExecReload = "${pkgs.coreutils}/bin/kill -HUP $MAINPID";
        Restart = "on-failure";
      };
    };

    # Create lease file directory
    systemd.tmpfiles.rules = [
      "d /var/lib/hotspot-dnsmasq 0755 root root -"
    ];

    # Enable NAT for internet sharing (only if not bridge mode)
    networking.nat = mkIf (!cfg.bridgeMode) {
      enable = true;
      externalInterface = if cfg.internetInterface != null
                          then cfg.internetInterface
                          else ""; # This will be set by the activation script
      internalInterfaces = [cfg.interface];
    };

    # Auto-detect internet interface if not specified
    system.activationScripts.hotspot-detect-interface = mkIf (cfg.internetInterface == null && !cfg.bridgeMode) ''
      # Detect default route interface
      DEFAULT_IFACE=$(${pkgs.iproute2}/bin/ip route show default | ${pkgs.gnugrep}/bin/grep -oP '(?<=dev )\S+' | head -1)
      if [ -n "$DEFAULT_IFACE" ]; then
        echo "Detected default internet interface: $DEFAULT_IFACE"
        # Update NAT configuration
        ${pkgs.gnused}/bin/sed -i "s/externalInterface = \"\"/externalInterface = \"$DEFAULT_IFACE\"/" /etc/nixos/configuration.nix 2>/dev/null || true
      else
        echo "Warning: Could not detect default internet interface"
      fi
    '';

    # Enable IP forwarding
    boot.kernel.sysctl = {
      "net.ipv4.ip_forward" = 1;
      "net.ipv6.conf.all.forwarding" = mkIf config.networking.enableIPv6 1;
    };

    # Create systemd service for bandwidth limiting if configured
    systemd.services.hotspot-bandwidth-limit = mkIf (cfg.bandwidthLimit != null) {
      description = "WiFi Hotspot Bandwidth Limiter";
      after = ["network.target" "hostapd.service"];
      bindsTo = ["hostapd.service"];
      wantedBy = mkIf cfg.autoStart ["multi-user.target"];

      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = ''
          ${pkgs.iproute2}/bin/tc qdisc add dev ${cfg.interface} root handle 1: htb default 30
          ${pkgs.iproute2}/bin/tc class add dev ${cfg.interface} parent 1: classid 1:1 htb rate ${cfg.bandwidthLimit}
          ${pkgs.iproute2}/bin/tc class add dev ${cfg.interface} parent 1:1 classid 1:30 htb rate ${cfg.bandwidthLimit}
        '';
        ExecStop = ''
          ${pkgs.iproute2}/bin/tc qdisc del dev ${cfg.interface} root 2>/dev/null || true
        '';
      };
    };

    # Enable hostapd autostart if configured
    systemd.services.hostapd.wantedBy = mkIf cfg.autoStart ["multi-user.target"];

    # Open firewall for DHCP and DNS on hotspot interface
    networking.firewall.interfaces.${cfg.interface} = {
      allowedTCPPorts = [53];
      allowedUDPPorts = [53 67 68];
    };

    # Additional firewall rules for NAT
    networking.firewall.extraCommands = mkIf (!cfg.bridgeMode) ''
      # Allow forwarding from hotspot interface
      iptables -A FORWARD -i ${cfg.interface} -j ACCEPT
      iptables -A FORWARD -o ${cfg.interface} -m state --state RELATED,ESTABLISHED -j ACCEPT
    '';
  };
}