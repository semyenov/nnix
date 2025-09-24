{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.modules.gnome;
in {
  options.modules.gnome = {
    enable =
      mkEnableOption "GNOME desktop environment"
      // {
        default = true;
      };

    wayland = mkOption {
      type = types.bool;
      default = true;
      description = "Enable Wayland support";
    };
  };

  config = mkIf cfg.enable {
    # X11/Wayland + GNOME
    services.xserver = {
      enable = true;
      displayManager.gdm = {
        enable = true;
        wayland = cfg.wayland;
      };
      desktopManager.gnome.enable = true;
      xkb = {
        layout = "us";
        variant = "";
        options = "caps:escape";
      };
    };

    # Printing support
    services.printing.enable = true;

    # Bluetooth support
    hardware.bluetooth = {
      enable = true;
      powerOnBoot = true;
    };

    # GNOME packages
    environment.systemPackages = with pkgs; [
      gnome-themes-extra
      adwaita-icon-theme
      gnomeExtensions.appindicator
      gnomeExtensions.dash-to-dock
      gnomeExtensions.just-perfection
      gnomeExtensions.user-themes
    ];

    # GNOME keyring
    security.pam.services = {
      gdm.enableGnomeKeyring = true;
      gdm-password.enableGnomeKeyring = true;
    };

    services.gnome = {
      gnome-keyring.enable = true;
      gnome-settings-daemon.enable = true;
    };

    # usbguard defaults are managed in modules/security.nix
  };
}
