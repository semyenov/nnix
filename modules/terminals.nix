{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.sozdev.terminals;
in {
  options.sozdev.terminals = {
    enable =
      mkEnableOption "Terminal emulators"
      // {
        default = true;
      };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      alacritty
      kitty
      ghostty
    ];
  };
}
