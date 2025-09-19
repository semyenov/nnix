{ config, lib, pkgs, ... }:

{
  imports = [ ../modules/services/docker.nix ];

  modules.services.docker = {
    enable = true;
    users = [ "semyenov" ];
  };

  # Enable NVIDIA in containers via toolkit when present
  hardware.nvidia-container-toolkit.enable = lib.mkDefault true;
}


