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

  sozdev.core.enable = true;
  sozdev.core.hostName = "semyenov";
  sozdev.core.timeZone = "Europe/Moscow";
  sozdev.core.locale = "en_US.UTF-8";

  # Enable NVIDIA GPU support
  sozdev.nvidia.enable = true;
  sozdev.nvidia.prime.enable = true;
  sozdev.nvidia.prime.intelBusId = "PCI:0:2:0";
  sozdev.nvidia.prime.nvidiaBusId = "PCI:1:0:0";

  # Enable Docker
  sozdev.docker.enable = true;
  sozdev.docker.enableOnBoot = true;
  sozdev.docker.enableNvidia = true;
  sozdev.docker.storageDriver = "overlay2";
  sozdev.docker.dockerComposePackage = pkgs.docker-compose;
  sozdev.docker.users = ["semyenov"];

  # Enable gaming
  sozdev.gaming.enable = true;

  # Additional system packages
  environment.systemPackages = with pkgs; [
    wsdd # Windows Service Discovery Daemon for network browsing
    gopass
    gopass-jsonapi
  ];

  # Enable WSDD service for Windows network discovery
  services.samba-wsdd = {
    enable = true;
    discovery = true;
    interface = "eno1"; # Your network interface
  };

  # Host-specific passwordless sudo for system management
  security.sudo.extraRules = [
    {
      users = ["semyenov"];
      commands = [
        {
          command = "/run/current-system/sw/bin/nixos-rebuild";
          options = ["NOPASSWD" "NOSETENV"];
        }
        {
          command = "/run/current-system/sw/bin/nix-collect-garbage";
          options = ["NOPASSWD" "NOSETENV"];
        }
        {
          command = "/run/current-system/sw/bin/systemctl";
          options = ["NOPASSWD" "NOSETENV"];
        }
        {
          command = "/run/current-system/sw/bin/nix-env";
          options = ["NOPASSWD" "NOSETENV"];
        }
        {
          command = "/run/current-system/sw/bin/nix-store";
          options = ["NOPASSWD" "NOSETENV"];
        }
      ];
    }
  ];

  system.stateVersion = "25.05";
}
