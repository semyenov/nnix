{
  config,
  pkgs,
  lib,
  inputs,
  ...
}: {
  home.packages = with pkgs; [
    # Bun JavaScript runtime and toolkit
    bun
  ];

  # Bun shell completions
  programs.fish.shellInit = lib.mkAfter ''
    if command -v bun >/dev/null
      bun completions fish | source
    end
  '';

  # Environment variables for Bun
  home.sessionVariables = {
    BUN_INSTALL = "$HOME/.bun";
  };

  # Add .bun/bin to PATH
  home.sessionPath = [
    "$HOME/.bun/bin"
  ];
}
