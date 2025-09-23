{
  config,
  pkgs,
  lib,
  inputs,
  ...
}: {
  home.packages = with pkgs; [
    # Shell Enhancements
    starship
    direnv
    atuin
    mcfly
    zellij
    navi
    vivid

    # Modern CLI Replacements
    lsd
    eza
    fd
    ripgrep
    bat
    dust
    duf
    procs
    btop
    bottom
    dog
    sd
    miller

    # File Management
    broot
    xplr
    ranger
    mc
    ncdu
    dua

    # Terminal Utilities
    tmux
    screen
    mosh
    asciinema
    expect

    # Data Processing
    jq
    yq
    visidata
    silicon

    # System Information
    neofetch
    onefetch
    lshw
    hwinfo
    pciutils
    usbutils
    dmidecode
    smartmontools

    # Archives
    p7zip
    unrar
    zip
    unzip

    # Fun
    cowsay
    lolcat
    cmatrix
  ];

  home.sessionVariables = {
    EDITOR = "nvim";
    BROWSER = "brave";
    TERMINAL = "ghostty";
  };

  programs.direnv = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };
}
