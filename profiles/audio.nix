{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.profiles.audio;
in {
  options.profiles.audio = {
    enable = mkEnableOption "Audio support with PipeWire" // {
      default = true;
    };

    enableJack = mkOption {
      type = types.bool;
      default = true;
      description = "Enable JACK audio support";
    };
  };

  config = mkIf cfg.enable {
    # Disable PulseAudio
    services.pulseaudio.enable = false;

    # Enable realtime kit for better audio performance
    security.rtkit.enable = true;

    # PipeWire configuration
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = cfg.enableJack;
    };
  };
}
