# Custom package overlay
final: prev: {
  cursor-appimage = final.callPackage ../packages/cursor-appimage.nix {};
  yandex-music = final.callPackage ../packages/yandex-music.nix {};
}
