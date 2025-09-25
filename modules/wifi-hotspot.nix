{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.sozdev.wifi-hotspot;
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
      description = "WPA2 passphrase for the hotspot (minimum 8 characters)";
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
      description = "Country code for regulatory domain";
    };

    gateway = mkOption {
      type = types.str;
      default = "192.168.12.1";
      description = "Gateway IP address for the hotspot network";
    };

    subnet = mkOption {
      type = types.str;
      default = "192.168.12.0/24";
      description = "Subnet for the hotspot network";
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
      description = "Interface connected to the internet for sharing (null to auto-detect)";
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

    wpa3 = mkOption {
      type = types.bool;
      default = false;
      description = "Enable WPA3 (requires compatible hardware)";
    };

    macAllowList = mkOption {
      type = types.listOf types.str;
      default = [];
      example = ["aa:bb:cc:dd:ee:ff"];
      description = "List of MAC addresses to allow (empty means allow all)";
    };

    macDenyList = mkOption {
      type = types.listOf types.str;
      default = [];
      example = ["aa:bb:cc:dd:ee:ff"];
      description = "List of MAC addresses to deny";
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
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.passphrase == "" || (builtins.stringLength cfg.passphrase >= 8);
        message = "WiFi hotspot passphrase must be at least 8 characters long or empty for open network";
      }
    ];

    # Enable hostapd for access point
    services.hostapd = {
      enable = true;
      radios.${cfg.interface} = {
        band = cfg.band;
        channel = cfg.channel;
        countryCode = cfg.countryCode;
        networks.${cfg.interface} = {
          ssid = cfg.ssid;
          authentication = mkMerge [
            {
              mode = if cfg.passphrase == "" then "none" else "wpa2-sha256";
              wpaPassphrase = mkIf (cfg.passphrase != "") cfg.passphrase;
            }
            (mkIf cfg.wpa3 {
              mode = "wpa3-sae";
              saePasswords = [{password = cfg.passphrase;}];
            })
          ];
          settings = {
            ieee80211n = true;
            ieee80211ac = mkIf (cfg.band == "5g") true;
            wmm_enabled = true;
            ignore_broadcast_ssid = mkIf cfg.hideSSID 1;
            ap_isolate = mkIf cfg.isolateClients 1;
          };
          macAllow = cfg.macAllowList;
          macDeny = cfg.macDenyList;
          macAcl =
            if cfg.macAllowList != [] then "allow"
            else if cfg.macDenyList != [] then "deny"
            else "deny";  # Default deny with empty lists means allow all
        };
      };
    };

    # Configure network interface
    networking.interfaces.${cfg.interface} = {
      ipv4.addresses = [{
        address = cfg.gateway;
        prefixLength = 24;
      }];
    };

    # Enable dnsmasq for DHCP and DNS
    services.dnsmasq = {
      enable = true;
      settings = {
        interface = cfg.interface;
        bind-interfaces = true;
        dhcp-range = "${cfg.dhcpRangeStart},${cfg.dhcpRangeEnd},12h";
        dhcp-option = [
          "option:router,${cfg.gateway}"
          "option:dns-server,${concatStringsSep "," cfg.dns}"
        ];
        server = cfg.dns;
        no-hosts = true;
        no-resolv = true;
      };
    };

    # Enable NAT for internet sharing
    networking.nat = {
      enable = true;
      externalInterface = cfg.internetInterface;
      internalInterfaces = [cfg.interface];
    };

    # Enable IP forwarding
    boot.kernel.sysctl = {
      "net.ipv4.ip_forward" = 1;
      "net.ipv6.conf.all.forwarding" = mkIf config.networking.enableIPv6 1;
    };

    # Create systemd service for bandwidth limiting if configured
    systemd.services.hotspot-bandwidth-limit = mkIf (cfg.bandwidthLimit != null) {
      description = "WiFi Hotspot Bandwidth Limiter";
      after = ["network.target" "hostapd.service"];
      wantedBy = ["multi-user.target"];
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

    # Auto-start configuration
    systemd.services.hostapd.wantedBy = mkIf cfg.autoStart ["multi-user.target"];
    systemd.services.dnsmasq.wantedBy = mkIf cfg.autoStart ["multi-user.target"];

    # Open firewall for DHCP and DNS on hotspot interface
    networking.firewall.interfaces.${cfg.interface} = {
      allowedTCPPorts = [53];
      allowedUDPPorts = [53 67 68];
    };
  };
}