{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.profiles.terminals;
in {
  options.profiles.terminals = {
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
