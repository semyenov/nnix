{pkgs}:
pkgs.appimageTools.wrapType2 rec {
  pname = "cursor";
  version = "1.6.35";

  src = pkgs.fetchurl {
    url = "https://downloads.cursor.com/production/b753cece5c67c47cb5637199a5a5de2b7100c18f/linux/x64/Cursor-${version}-x86_64.AppImage";
    sha256 = "1qpkvs6zga979hhki49blyckffjp9pk49vhfn9nv57bxgjrbqszb";
  };

  # Additional packages needed inside the FHS environment
  extraPkgs = pkgs:
    with pkgs; [
      # Core libraries
      libGL
      libGLU
      mesa # Provides libgbm.so.1

      # System libraries
      fontconfig
      freetype
      libnotify
      libuuid
      libsecret

      # Audio
      alsa-lib
      pulseaudio

      # Additional for native modules
      stdenv.cc.cc.lib
      libkrb5
      keyutils
    ];

  # Allow privilege escalation for sudo to work inside the sandbox
  # This reduces security but is necessary for some Cursor extensions
  extraBwrapArgs = [
    "--cap-add"
    "ALL"
  ];

  # Install desktop file and icons
  extraInstallCommands = let
    appimageContents = pkgs.appimageTools.extract {
      inherit pname version src;
    };
  in ''
    # Install desktop file if it exists
    if [ -f ${appimageContents}/cursor.desktop ]; then
      install -m 444 -D ${appimageContents}/cursor.desktop -t $out/share/applications
      substituteInPlace $out/share/applications/cursor.desktop \
        --replace-quiet 'Exec=AppRun' 'Exec=cursor' \
        --replace-quiet 'Exec=cursor' 'Exec=cursor'
      sed -i -E 's|^Icon=.*|Icon=cursor|' $out/share/applications/cursor.desktop
    fi

    # Find and install icon - try multiple common locations
    if [ -f ${appimageContents}/cursor.png ]; then
      install -m 444 -D ${appimageContents}/cursor.png \
        $out/share/icons/hicolor/512x512/apps/cursor.png
    elif [ -f ${appimageContents}/.DirIcon ]; then
      install -m 444 -D ${appimageContents}/.DirIcon \
        $out/share/icons/hicolor/512x512/apps/cursor.png
    elif [ -f ${appimageContents}/resources/app/resources/linux/code.png ]; then
      install -m 444 -D ${appimageContents}/resources/app/resources/linux/code.png \
        $out/share/icons/hicolor/512x512/apps/cursor.png
    elif [ -d ${appimageContents}/usr/share/icons ]; then
      # Find any icon in the extracted AppImage
      icon=$(find ${appimageContents}/usr/share/icons -name "*.png" -o -name "*.svg" | head -n1)
      if [ -n "$icon" ]; then
        install -m 444 -D "$icon" $out/share/icons/hicolor/512x512/apps/cursor.png
      fi
    fi
  '';

  meta = with pkgs.lib; {
    description = "AI-powered code editor built on VS Code";
    homepage = "https://cursor.com";
    license = licenses.unfree;
    platforms = ["x86_64-linux"];
    mainProgram = "cursor";
  };
}
