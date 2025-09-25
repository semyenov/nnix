{lib, ...}:
with lib; {
  imports = [
    ./core.nix
    ./users.nix
    ./audio.nix
    ./fonts.nix
    ./terminals.nix
    ./gnome.nix
    ./nvidia.nix
    ./docker.nix
    ./security.nix
    ./optimizations.nix
    ./gaming.nix
    ./wifi-hotspot.nix
  ];

  # Default sozdev configurations
  sozdev = {
    core.enable = mkDefault true;
    users.enable = mkDefault true;
    audio.enable = mkDefault true;
    fonts.enable = mkDefault true;
    terminals.enable = mkDefault true;
    gnome.enable = mkDefault true;
    nvidia.enable = mkDefault true;
    docker.enable = mkDefault true;
    security.enable = mkDefault true;
    optimizations.enable = mkDefault true;
    gaming.enable = mkDefault false;
    wifi-hotspot.enable = mkDefault false;
  };
}
