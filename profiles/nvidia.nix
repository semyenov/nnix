{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.profiles.nvidia;
in
{
  options.profiles.nvidia = {
    enable = mkEnableOption "NVIDIA GPU support" // {
      default = true;
    };

    prime = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable PRIME GPU offloading";
      };

      intelBusId = mkOption {
        type = types.str;
        default = "PCI:0:2:0";
        description = "Intel GPU PCI bus ID";
      };

      nvidiaBusId = mkOption {
        type = types.str;
        default = "PCI:1:0:0";
        description = "NVIDIA GPU PCI bus ID";
      };
    };
  };

  config = mkIf cfg.enable {
    # NVIDIA driver in xserver config
    services.xserver.videoDrivers = [ "nvidia" ];

    # Kernel parameters specific to NVIDIA; generic params are in optimizations
    boot.kernelParams = [ "nvidia-drm.modeset=1" ];
    boot.kernelModules = [ "nvidia" "nvidia_modeset" "nvidia_uvm" "nvidia_drm" ];

    # Enable redistributable firmware
    hardware.enableRedistributableFirmware = true;

    # NVIDIA configuration
    hardware.nvidia = {
      modesetting.enable = true;
      nvidiaSettings = true;
      open = false;
      powerManagement.enable = true;
      powerManagement.finegrained = false;
      package = config.boot.kernelPackages.nvidiaPackages.production;
    };

    # Graphics support
    hardware.graphics = {
      enable = true;
      enable32Bit = true;
    };

    # PRIME offloading
    hardware.nvidia.prime = mkIf cfg.prime.enable {
      offload = {
        enable = true;
        enableOffloadCmd = true;
      };
      intelBusId = cfg.prime.intelBusId;
      nvidiaBusId = cfg.prime.nvidiaBusId;
    };
  };
}