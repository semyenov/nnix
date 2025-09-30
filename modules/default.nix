{lib, ...}:
with lib; {
  imports = [
    ./core.nix
    ./users.nix
    ./audio.nix
    ./fonts.nix
    ./gnome.nix
    ./nvidia.nix
    ./docker.nix
    ./security.nix
    ./optimizations.nix
    ./gaming.nix
  ];

  # Default sozdev configurations
  sozdev = {
    core.enable = mkDefault true;
    users.enable = mkDefault true;
    audio.enable = mkDefault true;
    fonts.enable = mkDefault true;
    gnome.enable = mkDefault true;
    nvidia.enable = mkDefault false;
    docker.enable = mkDefault true;
    security.enable = mkDefault true;
    optimizations.enable = mkDefault true;
    gaming.enable = mkDefault false;
  };
}
