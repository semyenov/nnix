{
  config,
  pkgs,
  lib,
  inputs,
  ...
}: {
  home.packages = with pkgs; [
    # IDEs and Editors
    cursor-appimage
    unstable.claude-code
    postman
    neovim
    helix # Post-modern modal text editor
    zed-editor

    # Version Control
    gh
    gitlab
    gh-dash
    gitu
    gitui # Blazing fast terminal-ui for Git
    lazygit
    delta
    difftastic
    tig

    # Database Clients
    postgresql
    mariadb
    redis
    pgcli
    mycli
    litecli
    yaak

    # JavaScript/TypeScript Development
    unstable.bun # Fast all-in-one JavaScript runtime & toolkit
    fnm # Fast and simple Node.js version manager

    # Language Version Managers
    pyenv # Simple Python version management
    rbenv # Ruby version manager

    # Debugging & Profiling
    gdb
    valgrind
    hyperfine
    strace
    ltrace

    # Documentation
    cheat
    tealdeer

    # Code Analysis
    scc
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
