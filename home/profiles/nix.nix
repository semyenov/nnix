{pkgs, ...}: {
  home.packages = with pkgs; [
    nixpkgs-fmt # Nix formatter
    statix # Nix linter
    deadnix # Nix linter
    alejandra # Nix formatter
    nixd # Nix development tool
    nil # Nix language server
  ];
}
