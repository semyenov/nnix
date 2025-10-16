{pkgs}: let
  pname = "cursor";
  version = "1.7.44";

  src = pkgs.fetchurl {
    url = "https://downloads.cursor.com/production/9d178a4a5589981b62546448bb32920a8219a5de/linux/x64/Cursor-${version}-x86_64.AppImage";
    sha256 = "fde2dbebe102c459a9ce0b512207ced8f3e7dbc9056c0dd79aaf198cfac34398";
  };

  # Extract AppImage contents
  appimageContents = pkgs.appimageTools.extract {
    inherit pname version src;
  };
in
  pkgs.stdenv.mkDerivation {
    inherit pname version;

    src = appimageContents;

    nativeBuildInputs = [
      pkgs.makeWrapper
      pkgs.copyDesktopItems
      pkgs.autoPatchelfHook
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

      # Copy application files
      cp -r $src/usr/share/cursor/* $out/share/cursor/

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
      if [ -f $src/cursor.desktop ]; then
        cp $src/cursor.desktop $out/share/applications/
        substituteInPlace $out/share/applications/cursor.desktop \
          --replace 'Exec=AppRun' 'Exec=cursor' \
          --replace 'Icon=cursor' 'Icon=cursor'
        sed -i -E 's|^Icon=.*|Icon=cursor|' $out/share/applications/cursor.desktop
      fi

      # Install icon
      if [ -f $src/co.anysphere.cursor.png ]; then
        cp $src/co.anysphere.cursor.png $out/share/icons/hicolor/512x512/apps/cursor.png
      elif [ -f $src/code.png ]; then
        cp $src/code.png $out/share/icons/hicolor/512x512/apps/cursor.png
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
