{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.profiles.fonts;
in {
  options.profiles.fonts = {
    enable =
      mkEnableOption "Font configuration"
      // {
        default = true;
      };

    nerdFonts = mkOption {
      type = types.listOf types.str;
      default = ["RecursiveMono"];
      description = "Nerd fonts to install";
    };
  };

  config = mkIf cfg.enable {
    fonts = {
      packages = with pkgs; [
        nerd-fonts.recursive-mono
        noto-fonts
        noto-fonts-cjk-sans
        noto-fonts-emoji
        liberation_ttf
      ];

      fontconfig = {
        enable = true;
        defaultFonts = {
          serif = ["Noto Serif" "Liberation Serif"];
          sansSerif = ["Noto Sans" "Liberation Sans"];
          monospace = ["RecMonoLinear Nerd Font" "Noto Sans Mono"];
          emoji = ["Noto Color Emoji"];
        };
      };
    };
  };
}
