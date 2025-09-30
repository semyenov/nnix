{pkgs, ...}: {
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
    obs-studio
    unstable.tauon # Music player

    # Proxy Tools
    throne

    # System Utilities
    dconf
    gnome-tweaks
    adw-gtk3 # For legacy GNOME apps
  ];
}
