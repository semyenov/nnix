{pkgs}: let
  pname = "cursor";
  version = "1.7.46";

  src = pkgs.fetchurl {
    url = "https://downloads.cursor.com/production/b9e5948c1ad20443a5cecba6b84a3c9b99d62582/linux/x64/deb/amd64/deb/cursor_${version}_amd64.deb";
    sha256 = "0b41kcmr0migi6niqrppq42avf3lnddiv76762427dswz7ji3dhx";
  };
in
  pkgs.stdenv.mkDerivation {
    inherit pname version;

    src = src;

    nativeBuildInputs = [
      pkgs.makeWrapper
      pkgs.copyDesktopItems
      pkgs.autoPatchelfHook
      pkgs.dpkg
    ];

    buildInputs = [
      pkgs.stdenv.cc.cc.lib
      pkgs.libGL
      pkgs.libGLU
      pkgs.mesa
      pkgs.xorg.libX11
      pkgs.xorg.libXcomposite
      pkgs.xorg.libXdamage
      pkgs.xorg.libXext
      pkgs.xorg.libXfixes
      pkgs.xorg.libXrandr
      pkgs.xorg.libxcb
      pkgs.xorg.libxkbfile
      pkgs.libxkbcommon
      pkgs.wayland
      pkgs.fontconfig
      pkgs.freetype
      pkgs.libnotify
      pkgs.libuuid
      pkgs.libsecret
      pkgs.dbus
      pkgs.nspr
      pkgs.nss
      pkgs.cups
      pkgs.expat
      pkgs.alsa-lib
      pkgs.libpulseaudio
      pkgs.libkrb5
      pkgs.keyutils
      pkgs.at-spi2-atk
      pkgs.at-spi2-core
      pkgs.cairo
      pkgs.gdk-pixbuf
      pkgs.glib
      pkgs.gtk3
      pkgs.pango
    ];

    installPhase = ''
      runHook preInstall

      # Create directories
      mkdir -p $out/bin $out/share/cursor $out/share/applications $out/share/icons/hicolor/512x512/apps

      # Extract deb and copy application files
      extract_dir=$(mktemp -d)
      dpkg-deb -x ${src} "$extract_dir"
      cp -r "$extract_dir"/usr/share/cursor/* $out/share/cursor/

      # Create wrapper script
      makeWrapper $out/share/cursor/cursor $out/bin/cursor \
        --prefix LD_LIBRARY_PATH : "${pkgs.lib.makeLibraryPath [
        pkgs.stdenv.cc.cc.lib
        pkgs.libGL
        pkgs.libGLU
        pkgs.mesa
        pkgs.xorg.libX11
        pkgs.xorg.libXcomposite
        pkgs.xorg.libXdamage
        pkgs.xorg.libXext
        pkgs.xorg.libXfixes
        pkgs.xorg.libXrandr
        pkgs.xorg.libxcb
        pkgs.xorg.libxkbfile
        pkgs.google-chrome
        pkgs.libxkbcommon
        pkgs.wayland
        pkgs.fontconfig
        pkgs.freetype
        pkgs.libnotify
        pkgs.libuuid
        pkgs.libsecret
        pkgs.dbus
        pkgs.nspr
        pkgs.nss
        pkgs.cups
        pkgs.expat
        pkgs.alsa-lib
        pkgs.libpulseaudio
        pkgs.libkrb5
        pkgs.keyutils
        pkgs.at-spi2-atk
        pkgs.at-spi2-core
        pkgs.cairo
        pkgs.gdk-pixbuf
        pkgs.glib
        pkgs.gtk3
        pkgs.pango
      ]}" \
        --add-flags "--no-sandbox" \
        --add-flags "--disable-gpu-sandbox" \
        --add-flags "--disable-dev-shm-usage"

      # Install desktop file
      if [ -f "$extract_dir"/usr/share/applications/cursor.desktop ]; then
        cp "$extract_dir"/usr/share/applications/cursor.desktop $out/share/applications/
        substituteInPlace $out/share/applications/cursor.desktop \
          --replace 'Exec=AppRun' 'Exec=cursor' \
          --replace 'Icon=cursor' 'Icon=cursor'
        sed -i -E 's|^Icon=.*|Icon=cursor|' $out/share/applications/cursor.desktop
      fi

      # Install icon
      if [ -f "$extract_dir"/usr/share/icons/hicolor/512x512/apps/co.anysphere.cursor.png ]; then
        cp "$extract_dir"/usr/share/icons/hicolor/512x512/apps/co.anysphere.cursor.png $out/share/icons/hicolor/512x512/apps/cursor.png
      elif [ -f "$extract_dir"/usr/share/pixmaps/code.png ]; then
        cp "$extract_dir"/usr/share/pixmaps/code.png $out/share/icons/hicolor/512x512/apps/cursor.png
      fi

      runHook postInstall
    '';

    meta = {
      description = "AI-powered code editor built on VS Code";
      homepage = "https://cursor.com";
      license = pkgs.lib.licenses.unfree;
      platforms = ["x86_64-linux"];
      mainProgram = "cursor";
    };
  }
