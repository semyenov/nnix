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
  profiles.core.hostName = "nixos";
  profiles.core.timeZone = "Europe/Moscow";
  profiles.core.locale = "en_US.UTF-8";

  profiles.docker.enable = true;
  profiles.docker.enableOnBoot = true;
  profiles.docker.enableNvidia = true;
  profiles.docker.storageDriver = "overlay2";
  profiles.docker.dockerComposePackage = pkgs.docker-compose;
  profiles.docker.users = ["semyenov"];

  
  system.stateVersion = "25.05";
}
