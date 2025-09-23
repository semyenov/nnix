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
    zed

    # Version Control
    gh
    gitlab
    gh-dash
    gitu
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
}
