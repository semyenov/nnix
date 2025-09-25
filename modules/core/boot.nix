{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.sozdev.core.boot;
in {
  options.sozdev.core.boot = {
    enable = mkEnableOption "Boot configuration" // {
      default = true;
    };

    loader = mkOption {
      type = types.enum ["systemd-boot" "grub"];
      default = "systemd-boot";
      description = "Boot loader to use";
    };

    timeout = mkOption {
      type = types.int;
      default = 3;
      description = "Boot menu timeout in seconds";
    };

    configurationLimit = mkOption {
      type = types.int;
      default = 5;
      description = "Number of boot configurations to keep";
    };

    cleanTmpOnBoot = mkOption {
      type = types.bool;
      default = true;
      description = "Clean /tmp directory on boot";
    };
  };

  config = mkIf cfg.enable {
    boot = {
      loader = mkMerge [
        (mkIf (cfg.loader == "systemd-boot") {
          systemd-boot = {
            enable = true;
            configurationLimit = cfg.configurationLimit;
          };
          efi.canTouchEfiVariables = true;
          timeout = cfg.timeout;
        })
        (mkIf (cfg.loader == "grub") {
          grub = {
            enable = true;
            device = "nodev";
            efiSupport = true;
            configurationLimit = cfg.configurationLimit;
          };
          efi.canTouchEfiVariables = true;
          timeout = cfg.timeout;
        })
      ];

      tmp.cleanOnBoot = cfg.cleanTmpOnBoot;
    };
  };
}