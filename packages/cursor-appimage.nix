{
  pkgs,
  lib,
}:
# Official Cursor AppImage with fixes for native modules
pkgs.appimageTools.wrapType2 {
  name = "cursor";
  pname = "cursor";
  version = "1.6.35";
  src = pkgs.fetchurl {
    url = "https://downloads.cursor.com/production/b753cece5c67c47cb5637199a5a5de2b7100c18f/linux/x64/Cursor-1.6.35-x86_64.AppImage";
    sha256 = "1qpkvs6zga979hhki49blyckffjp9pk49vhfn9nv57bxgjrbqszb";
  };

  # Fix for native modules
  extraInstallCommands = ''
    # Extract AppImage contents once for assets
    extracted=${pkgs.appimageTools.extract {
      pname = "cursor";
      version = "1.6.35";
      src = pkgs.fetchurl {
        url = "https://downloads.cursor.com/production/b753cece5c67c47cb5637199a5a5de2b7100c18f/linux/x64/Cursor-1.6.35-x86_64.AppImage";
        sha256 = "1qpkvs6zga979hhki49blyckffjp9pk49vhfn9nv57bxgjrbqszb";
      };
    }}

    # Install desktop entry and fix Exec/Icon
    install -m 444 -D "$extracted/cursor.desktop" -t $out/share/applications
    substituteInPlace $out/share/applications/cursor.desktop \
      --replace 'Exec=AppRun' 'Exec=cursor'
    # Ensure a stable icon name and install the best available resolution
    iconInstalled=0
    # Prefer scalable SVG if present
    if [ -d "$extracted/usr/share/icons/hicolor/scalable/apps" ]; then
      svgSrc=$(find "$extracted/usr/share/icons/hicolor/scalable/apps" -maxdepth 1 -type f -name "*.svg" | head -n1 || true)
      if [ -n "$svgSrc" ]; then
        mkdir -p $out/share/icons/hicolor/scalable/apps
        install -m 444 "$svgSrc" $out/share/icons/hicolor/scalable/apps/cursor.svg
        iconInstalled=1
      fi
    fi

    # Otherwise pick the largest available PNG
    if [ "$iconInstalled" -eq 0 ]; then
      for size in 1024x1024 512x512 256x256 128x128 64x64 48x48 32x32 24x24 16x16; do
        if [ -d "$extracted/usr/share/icons/hicolor/$size/apps" ]; then
          pngSrc=$(find "$extracted/usr/share/icons/hicolor/$size/apps" -maxdepth 1 -type f -name "*.png" | head -n1 || true)
          if [ -n "$pngSrc" ]; then
            mkdir -p $out/share/icons/hicolor/$size/apps
            install -m 444 "$pngSrc" $out/share/icons/hicolor/$size/apps/cursor.png
            iconInstalled=1
            break
          fi
        fi
      done
    fi

    # Fallbacks
    if [ "$iconInstalled" -eq 0 ] && [ -f "$extracted/usr/share/pixmaps/cursor.png" ]; then
      mkdir -p $out/share/icons/hicolor/512x512/apps
      install -m 444 "$extracted/usr/share/pixmaps/cursor.png" $out/share/icons/hicolor/512x512/apps/cursor.png
      iconInstalled=1
    fi
    if [ "$iconInstalled" -eq 0 ] && [ -f "$extracted/.DirIcon" ]; then
      mkdir -p $out/share/icons/hicolor/512x512/apps
      install -m 444 "$extracted/.DirIcon" $out/share/icons/hicolor/512x512/apps/cursor.png
      iconInstalled=1
    fi
    if [ "$iconInstalled" -eq 0 ] && [ -f "$extracted/cursor.png" ]; then
      mkdir -p $out/share/icons/hicolor/512x512/apps
      install -m 444 "$extracted/cursor.png" $out/share/icons/hicolor/512x512/apps/cursor.png
      iconInstalled=1
    fi

    # Point desktop entry to theme icon name 'cursor'
    sed -i 's/^Icon=.*/Icon=cursor/' $out/share/applications/cursor.desktop

    # Create symlink for the binary (case-insensitive alias)
    mkdir -p $out/bin
    ln -s $out/bin/cursor $out/bin/Cursor || true
  '';

  extraPkgs = pkgs:
    with pkgs; [
      # X11 libraries
      xorg.libX11
      xorg.libXcursor
      xorg.libXrandr
      xorg.libXinerama
      xorg.libXi
      xorg.libXfixes
      xorg.libXrender
      xorg.libXext
      xorg.libXtst
      xorg.libXcomposite
      xorg.libXdamage
      xorg.libxcb
      xorg.libXScrnSaver
      libxkbcommon

      # Graphics
      libGL
      libGLU
      mesa
      vulkan-loader
      libdrm

      # GTK/System
      glib
      gtk3
      cairo
      pango
      atk
      gdk-pixbuf
      at-spi2-atk
      at-spi2-core

      # Audio
      alsa-lib
      pulseaudio

      # System libraries
      fontconfig
      freetype
      dbus
      nss
      nspr
      cups
      expat
      libnotify
      libuuid
      libsecret
      systemd

      # Additional libraries for native modules
      stdenv.cc.cc.lib
      xorg.libxkbfile
      libkrb5
      keyutils
      e2fsprogs
      util-linux
    ];
}
