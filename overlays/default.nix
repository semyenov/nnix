# Custom package overlay
final: prev: {
  cursor-appimage = final.callPackage ../packages/cursor-appimage.nix {};
}
