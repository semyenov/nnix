{pkgs, ...}: {
  # Fish plugins using NixOS native fishPlugins
  # Note: Oh My Fish framework doesn't work well with NixOS due to read-only store conflicts
  # Using fishPlugins instead for equivalent functionality
  home.packages = with pkgs.fishPlugins; [
    tide # Ultimate Fish prompt - double-line theme with git info
    bang-bang # Bash-style history substitution (!!, !$)
    fzf-fish # Fuzzy finder integration
  ];

  # Configure fish to load these plugins
  programs.fish.plugins = [
    {
      name = "tide";
      src = pkgs.fishPlugins.tide.src;
    }
    {
      name = "bang-bang";
      src = pkgs.fishPlugins.bang-bang.src;
    }
    {
      name = "fzf-fish";
      src = pkgs.fishPlugins.fzf-fish.src;
    }
  ];

  # Enable fish if not already enabled elsewhere
  programs.fish.enable = true;

  # Tide configuration (runs on first launch)
  # You can customize tide by running: tide configure
  programs.fish.interactiveShellInit = ''
    # Set tide to use double-line prompt by default
    set -g tide_prompt_add_newline_before true
  '';
}
