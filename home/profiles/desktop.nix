{ config, pkgs, lib, inputs, ... }:

{
  home.packages = with pkgs; [
    # Communication
    telegram-desktop
    
    # Browsers
    brave chromium
    
    # Development
    cursor-appimage jetbrains.idea-community postman
    unstable.claude-code
    
    # Media
    vlc spotify yandex-music gimp inkscape obs-studio
    
    # Productivity
    obsidian libreoffice thunderbird
    
    # System utilities
    dconf gnome-tweaks
    
    # Shell tools
    starship direnv atuin mcfly broot skim navi tealdeer zellij
    gh-dash gitu silicon onefetch scc pgcli litecli visidata dua xplr vivid
    
    # Fun
    neofetch cowsay lolcat cmatrix
  ];

  home.sessionVariables = {
    EDITOR = "nvim";
    BROWSER = "brave";
    TERMINAL = "ghostty";
  };
}