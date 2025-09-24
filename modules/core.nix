{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
with lib; let
  cfg = config.sozdev.core;
in {
  options.sozdev.core = {
    enable =
      mkEnableOption "Core system configuration"
      // {
        default = true;
      };

    hostName = mkOption {
      type = types.str;
      default = "nixos";
      description = "System hostname";
    };

    timeZone = mkOption {
      type = types.str;
      default = "UTC";
      description = "System timezone";
    };

    locale = mkOption {
      type = types.str;
      default = "en_US.UTF-8";
      description = "System locale";
    };
  };

  config = mkIf cfg.enable {
    # Boot loader configuration
    boot.loader = {
      systemd-boot.enable = true;
      systemd-boot.configurationLimit = 5;
      efi.canTouchEfiVariables = true;
      timeout = 3;
    };

    # Clean /tmp on boot
    boot.tmp.cleanOnBoot = true;

    # Networking
    networking = {
      hostName = cfg.hostName;
      firewall.enable = true;
      networkmanager.enable = true;
    };

    # Time and locale
    time.timeZone = cfg.timeZone;
    i18n = {
      defaultLocale = cfg.locale;
      extraLocaleSettings = {
        LC_ADDRESS = cfg.locale;
        LC_IDENTIFICATION = cfg.locale;
        LC_MEASUREMENT = cfg.locale;
        LC_MONETARY = cfg.locale;
        LC_NAME = cfg.locale;
        LC_NUMERIC = cfg.locale;
        LC_PAPER = cfg.locale;
        LC_TELEPHONE = cfg.locale;
        LC_TIME = cfg.locale;
      };
    };

    # Console configuration
    console = {
      font = "Lat2-Terminus16";
      useXkbConfig = true;
    };

    # Nix settings
    nixpkgs.config.allowUnfree = true;

    nix = {
      package = pkgs.nixVersions.stable;
      settings = {
        experimental-features = ["nix-command" "flakes"];
        auto-optimise-store = true;
        substituters = [
          "https://cache.nixos.org"
          "https://nix-community.cachix.org"
        ];
        trusted-public-keys = [
          "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
          "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        ];
        trusted-users = ["semyenov" "@wheel"];
      };
      gc = {
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than 30d";
      };
      optimise.automatic = true;
    };

    # Essential services
    services.fwupd.enable = true;

    # Command not found handler
    programs.command-not-found = {
      enable = true;
      dbPath = inputs.flake-programs-sqlite.packages.${pkgs.system}.programs-sqlite;
    };
  };
}
