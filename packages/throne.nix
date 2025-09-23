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
        mkdir -p $out/share/applications
        mkdir -p $out/share/icons/hicolor/256x256/apps

        # Install binary (the extracted binary is called 'Throne')
        install -m 755 Throne/Throne $out/bin/throne

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
