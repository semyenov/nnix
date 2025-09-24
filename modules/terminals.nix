{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.modules.terminals;
in {
  options.modules.terminals = {
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
