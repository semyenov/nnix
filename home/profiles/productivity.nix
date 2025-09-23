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
    zotero
    libreoffice

    # Media
    vlc
    spotify
    gimp
    inkscape
    obs-studio

    # System Utilities
    dconf
    gnome-tweaks
  ];
}
