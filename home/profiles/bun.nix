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

    # Node.js runtimes (for compatibility)
    nodejs_22
    nodejs_20

    # Package managers
    yarn
    pnpm

    # Build tools and bundlers
    esbuild
    vite
    webpack
    rollup
    parcel

    # TypeScript tooling
    typescript
    ts-node
    typecheck

    # Linting and formatting
    eslint_d
    prettierd
    biome

    # Testing frameworks
    vitest
    playwright
    cypress

    # Development servers and tools
    serve
    http-server
    nodemon
    concurrently

    # Database tools for Node.js
    sqlite
    prisma-engines

    # Debugging and profiling
    clinic
    0x
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