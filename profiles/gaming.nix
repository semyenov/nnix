{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.profiles.gaming;
in {
  options.profiles.gaming = {
    enable =
      mkEnableOption "Gaming tweaks: Steam, GameMode, MangoHud, 32-bit GL, CS 1.6 ports"
      // {
        default = false;
      };

    openCSPorts = mkOption {
      type = types.bool;
      default = false;
      description = "Open typical Counter-Strike 1.6 server/client ports in firewall";
    };

    steamPackage = mkOption {
      type = types.package;
      default = pkgs.steam;
      description = "Steam package to install";
    };
  };

  config = mkIf cfg.enable {
    # 32-bit graphics and Vulkan
    hardware.graphics = {
      enable = true;
      enable32Bit = true;
    };

    # Feral GameMode for performance
    programs.gamemode = {
      enable = true;
      settings = {
        general = {
          renice = 10;
          ioprio = 0;
          inhibit_screensaver = 1;
        };
      };
    };

    # Steam
    programs.steam = {
      enable = true;
      package = cfg.steamPackage;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = false;
    };

    # Common game tools
    environment.systemPackages = with pkgs; [
      lutris
      protonup-qt
      mangohud
      gamemode
      wineWowPackages.stable
      winetricks
      vulkan-tools
      vulkan-validation-layers
      glxinfo
    ];

    # Optional: open CS 1.6 ports
    networking.firewall = mkIf cfg.openCSPorts {
      allowedTCPPorts = [27015 27020 26900];
      allowedUDPPorts = [27005 27015 27020 26900 1200];
    };
  };
}
