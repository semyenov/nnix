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

    # Don't automatically unpack - we handle extraction manually in installPhase
    dontUnpack = true;

    nativeBuildInputs = [
      pkgs.makeWrapper
      pkgs.copyDesktopItems
      pkgs.autoPatchelfHook
      pkgs.binutils
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

    desktopItems = [
      (pkgs.makeDesktopItem {
        name = "cursor";
        desktopName = "Cursor";
        comment = "AI-powered code editor";
        exec = "cursor %F";
        icon = "cursor";
        startupNotify = true;
        startupWMClass = "Cursor";
        categories = ["Development" "TextEditor" "IDE"];
        mimeTypes = ["text/plain" "inode/directory"];
        keywords = ["cursor" "code" "editor" "ide" "vscode"];
      })
    ];

    installPhase = ''
      runHook preInstall

      # Create directories
      mkdir -p $out/bin $out/share/cursor $out/share/applications $out/share/icons/hicolor/512x512/apps

      # Extract deb and copy application files
      extract_dir=$(mktemp -d)

      # Extract .deb archive manually to avoid permission issues with setuid binaries
      ar x ${src} --output="$extract_dir"

      # Extract the data archive (can be data.tar.xz, data.tar.gz, or data.tar.zst)
      cd "$extract_dir"
      if [ -f data.tar.xz ]; then
        tar xf data.tar.xz --no-same-owner --no-same-permissions
      elif [ -f data.tar.gz ]; then
        tar xzf data.tar.gz --no-same-owner --no-same-permissions
      elif [ -f data.tar.zst ]; then
        tar xf data.tar.zst --no-same-owner --no-same-permissions
      fi
      cd -

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

      # Install desktop files using copyDesktopItems
      copyDesktopItems

      # Install icon
      if [ -f "$extract_dir"/usr/share/icons/hicolor/512x512/apps/co.anysphere.cursor.png ]; then
        cp "$extract_dir"/usr/share/icons/hicolor/512x512/apps/co.anysphere.cursor.png $out/share/icons/hicolor/512x512/apps/cursor.png
      elif [ -f "$extract_dir"/usr/share/pixmaps/code.png ]; then
        cp "$extract_dir"/usr/share/pixmaps/code.png $out/share/icons/hicolor/512x512/apps/cursor.png
      else
        # Fallback: create a symlink to ensure icon is available
        mkdir -p $out/share/icons/hicolor/512x512/apps
        if [ -f "$extract_dir"/usr/share/cursor/resources/app/resources/linux/code.png ]; then
          cp "$extract_dir"/usr/share/cursor/resources/app/resources/linux/code.png $out/share/icons/hicolor/512x512/apps/cursor.png
        fi
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
