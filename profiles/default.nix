{...}: {
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
  ];

  # Default profile configurations
  profiles = {
    core.enable = true;
    users.enable = true;
    audio.enable = true;
    fonts.enable = true;
    terminals.enable = true;
    gnome.enable = true;
    nvidia.enable = true;
    docker.enable = true;
    security.enable = true;
  };
}
