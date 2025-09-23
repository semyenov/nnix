{
  pkgs,
  lib,
}:
pkgs.stdenv.mkDerivation rec {
  pname = "yandex-music";
  version = "5.67.0";

  src = pkgs.fetchurl {
    url = "https://music-desktop-application.s3.yandex.net/stable/Yandex_Music_amd64_${version}.deb";
    sha256 = "0p3df9lnqdi4vsprg020978ky1kxyxr3fsjvxmybd3ydr8rnl8ak";
  };

  nativeBuildInputs = with pkgs; [
    dpkg
    autoPatchelfHook
  ];

  buildInputs = with pkgs; [
    # Common dependencies for electron apps
    alsa-lib
    at-spi2-atk
    at-spi2-core
    cairo
    cups
    dbus
    expat
    fontconfig
    freetype
    gdk-pixbuf
    glib
    gtk3
    xorg.libX11
    xorg.libXcomposite
    xorg.libXcursor
    xorg.libXdamage
    xorg.libXext
    xorg.libXfixes
    xorg.libXi
    xorg.libXinerama
    xorg.libXrandr
    xorg.libXrender
    xorg.libXScrnSaver
    xorg.libXtst
    xorg.libxcb
    libxkbcommon
    xorg.libxkbfile
    mesa
    nspr
    nss
    pango
    systemd
    xorg.libXScrnSaver
  ];

  unpackPhase = ''
    dpkg-deb -x $src .
  '';

  installPhase = ''
    mkdir -p $out

    # Copy usr directory contents
    if [ -d usr ]; then
      cp -r usr/* $out/
    fi

    # Copy opt directory contents, preserving structure
    if [ -d opt ]; then
      cp -r opt $out/
    fi

    # Create desktop entry
    mkdir -p $out/share/applications
    substituteInPlace $out/share/applications/yandexmusic.desktop \
      --replace-fail "/opt/Яндекс Музыка" "$out/opt/Яндекс Музыка"

    # Create symlink for the binary
    mkdir -p $out/bin
    ln -s "$out/opt/Яндекс Музыка/yandexmusic" $out/bin/yandex-music
  '';

  # Fix broken symlinks check
  preFixup = ''
    # Ensure the binary exists before creating symlink
    if [ ! -f "$out/opt/Яндекс Музыка/yandexmusic" ]; then
      echo "Binary not found at expected location"
      exit 1
    fi
  '';

  meta = with lib; {
    description = "Yandex Music desktop application";
    homepage = "https://music.yandex.ru/";
    license = licenses.unfree;
    platforms = ["x86_64-linux"];
    maintainers = [];
  };
}
