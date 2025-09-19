{ pkgs, lib }:

# Official Cursor AppImage with fixes for native modules
pkgs.appimageTools.wrapType2 {
  name = "cursor";
  pname = "cursor";
  version = "1.5.11";
  src = pkgs.fetchurl {
    url = "https://downloads.cursor.com/production/2f2737de9aa376933d975ae30290447c910fdf46/linux/x64/Cursor-1.5.11-x86_64.AppImage";
    sha256 = "01mc33h6rw0z0v5y6ai6gr3pay5rg1a960q6f62aks6yq20lymiy";
  };

  # Fix for native modules
  extraInstallCommands = ''
    # Install desktop entry
    install -m 444 -D ${pkgs.appimageTools.extract {
      pname = "cursor";
      version = "1.5.11";
      src = pkgs.fetchurl {
        url = "https://downloads.cursor.com/production/2f2737de9aa376933d975ae30290447c910fdf46/linux/x64/Cursor-1.5.11-x86_64.AppImage";
        sha256 = "01mc33h6rw0z0v5y6ai6gr3pay5rg1a960q6f62aks6yq20lymiy";
      };
    }}/cursor.desktop -t $out/share/applications
    substituteInPlace $out/share/applications/cursor.desktop \
      --replace 'Exec=AppRun' 'Exec=cursor'

    # Create symlink for the binary
    mkdir -p $out/bin
    ln -s $out/bin/cursor $out/bin/Cursor || true
  '';

  extraPkgs = pkgs: with pkgs; [
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
