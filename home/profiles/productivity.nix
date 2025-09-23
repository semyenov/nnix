{
  config,
  pkgs,
  lib,
  inputs,
  ...
}: {
  home.packages = with pkgs; [
    # Communication
    telegram-desktop
    thunderbird

    # Browsers
    brave
    chromium

    # Office & Documentation
    obsidian
    libreoffice

    # Media
    vlc
    spotify
    unstable.yandex-music
    gimp
    inkscape
    obs-studio

    # System Utilities
    dconf
    gnome-tweaks
  ];
}
