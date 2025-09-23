# Custom package overlay
final: prev: {
  cursor-appimage = final.callPackage ../packages/cursor-appimage.nix {};
  throne = final.callPackage ../packages/throne.nix {};
}
