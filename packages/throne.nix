{
  pkgs,
  lib,
}:
# Throne - Cross-platform GUI proxy utility powered by sing-box
pkgs.stdenv.mkDerivation rec {
  pname = "throne";
  version = "1.0.6";

  src = pkgs.fetchurl {
    url = "https://github.com/throneproj/Throne/releases/download/${version}/Throne-${version}-linux-amd64.zip";
    sha256 = "e3b2a49e70049d3aa6cab6767cad9ab0c2f186bc6f61a99017845fa8e7f78ae4";
  };

  nativeBuildInputs = with pkgs; [
    unzip
    autoPatchelfHook
    qt6.wrapQtAppsHook
    makeWrapper
  ];

  buildInputs = with pkgs; [
    # Qt6 dependencies
    qt6.qtbase
    qt6.qtsvg
    qt6.qtwayland

    # System libraries
    stdenv.cc.cc.lib
    glibc
    libGL
    libglvnd

    # X11 libraries
    xorg.libX11
    xorg.libXext
    xorg.libXrender
    xorg.libXrandr
    xorg.libXinerama
    xorg.libXcursor
    xorg.libXi
    xorg.libXfixes
    xorg.libXcomposite
    xorg.libXdamage
    xorg.libxcb
    xorg.libXScrnSaver

    # Other system dependencies
    fontconfig
    freetype
    zlib
    dbus
    glib
    cairo
    pango
    gtk3
    atk
    gdk-pixbuf
  ];

  unpackPhase = ''
    unzip $src
  '';

  installPhase = ''
    runHook preInstall

    # Create directories
    mkdir -p $out/bin
    mkdir -p $out/lib/throne
    mkdir -p $out/share/applications
    mkdir -p $out/share/icons/hicolor/256x256/apps

    # Install all files from the Throne directory
    cp -r Throne/* $out/lib/throne/

    # Create runtime wrapper for GUI
    cat > $out/bin/throne << EOF
    #!${pkgs.runtimeShell}
    set -e

    # Use simple approach for XDG data home
    if [ -z "\$XDG_DATA_HOME" ]; then
      XDG_DATA_HOME="\$HOME/.local/share"
    fi
    APPDIR="\$XDG_DATA_HOME/throne"
    STORE_DIR="$out/lib/throne"
    HOME_DIR="\$APPDIR"

    mkdir -p "\$APPDIR"

    # Copy all files to user-writable location
    cp -rf "\$STORE_DIR"/* "\$HOME_DIR"/
    chmod +x "\$HOME_DIR/Throne"

    # Run the GUI
    exec "\$HOME_DIR/Throne" "\$@"
    EOF
    chmod +x $out/bin/throne

    # Create wrapper for core component
    cat > $out/bin/throne-core << EOF
    #!${pkgs.runtimeShell}
    set -e

    # Use simple approach for XDG data home
    if [ -z "\$XDG_DATA_HOME" ]; then
      XDG_DATA_HOME="\$HOME/.local/share"
    fi
    APPDIR="\$XDG_DATA_HOME/throne"
    STORE_DIR="$out/lib/throne"
    HOME_DIR="\$APPDIR"

    # Ensure core binary exists in user-writable location
    if [ ! -f "\$HOME_DIR/core" ]; then
      cp -f "\$STORE_DIR/core" "\$HOME_DIR/core"
      chmod +x "\$HOME_DIR/core"
    fi

    # Run the core
    exec "\$HOME_DIR/core" "\$@"
    EOF
    chmod +x $out/bin/throne-core

    # Install icon if it exists
    if [ -f Throne/Throne.png ]; then
      install -m 644 Throne/Throne.png $out/share/icons/hicolor/256x256/apps/throne.png
    fi

    # Create desktop entry
    cat > $out/share/applications/throne.desktop << EOF
    [Desktop Entry]
    Type=Application
    Name=Throne
    Comment=Cross-platform GUI proxy utility powered by sing-box
    Exec=throne
    Icon=throne
    Categories=Network;Security;
    Terminal=false
    EOF

    runHook postInstall
  '';

  postFixup = '''';

  meta = with lib; {
    description = "Cross-platform GUI proxy utility powered by sing-box";
    longDescription = ''
      Throne is a cross-platform GUI proxy utility that supports multiple network protocols
      including SOCKS, HTTP(S), Shadowsocks, Trojan, VMess, VLESS, and more.
      It supports various subscription formats and is a continuation of the Nekoray project.
    '';
    homepage = "https://github.com/throneproj/Throne";
    license = licenses.gpl3Plus;
    platforms = ["x86_64-linux"];
    maintainers = [];
    mainProgram = "throne";
  };
}
