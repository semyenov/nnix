{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    ../../profiles
  ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken.

  profiles.core.enable = true;
  profiles.core.hostName = "semyenov";
  profiles.core.timeZone = "Europe/Moscow";
  profiles.core.locale = "en_US.UTF-8";

  # Set domain to make the FQDN "semyenov"
  networking.domain = "local";

  profiles.docker.enable = true;
  profiles.docker.enableOnBoot = true;
  profiles.docker.enableNvidia = true;
  profiles.docker.storageDriver = "overlay2";
  profiles.docker.dockerComposePackage = pkgs.docker-compose;
  profiles.docker.users = ["semyenov"];

  profiles.gaming.enable = true;

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

  system.stateVersion = "25.05";
}
