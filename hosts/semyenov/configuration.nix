{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    ../../modules
  ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken.

  modules.core.enable = true;
  modules.core.hostName = "semyenov";
  modules.core.timeZone = "Europe/Moscow";
  modules.core.locale = "en_US.UTF-8";

  # Set domain to make the FQDN "semyenov"
  networking.domain = "local";

  modules.docker.enable = true;
  modules.docker.enableOnBoot = true;
  modules.docker.enableNvidia = true;
  modules.docker.storageDriver = "overlay2";
  modules.docker.dockerComposePackage = pkgs.docker-compose;
  modules.docker.users = ["semyenov"];

  modules.gaming.enable = true;

  # Additional system packages
  environment.systemPackages = with pkgs; [
    wsdd # Windows Service Discovery Daemon for network browsing
  ];

  # Enable WSDD service for Windows network discovery
  services.samba-wsdd = {
    enable = true;
    discovery = true;
    interface = "eno1"; # Your network interface
  };

  # BlueTooth configuration
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings = {
      General = {
        Enable = "Source,Sink,Media,Socket";
        Experimental = true;
      };
    };
  };

  # Enable blueman for Bluetooth GUI management
  services.blueman.enable = true;

  # Host-specific passwordless sudo for system management
  security.sudo.extraRules = [
    {
      users = [ "semyenov" ];
      commands = [
        {
          command = "/run/current-system/sw/bin/nixos-rebuild";
          options = [ "NOPASSWD" "NOSETENV" ];
        }
        {
          command = "/run/current-system/sw/bin/nix-collect-garbage";
          options = [ "NOPASSWD" "NOSETENV" ];
        }
        {
          command = "/run/current-system/sw/bin/systemctl";
          options = [ "NOPASSWD" "NOSETENV" ];
        }
        {
          command = "/run/current-system/sw/bin/nix-env";
          options = [ "NOPASSWD" "NOSETENV" ];
        }
        {
          command = "/run/current-system/sw/bin/nix-store";
          options = [ "NOPASSWD" "NOSETENV" ];
        }
      ];
    }
  ];

  system.stateVersion = "25.05";
}
