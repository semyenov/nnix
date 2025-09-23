{
  config,
  pkgs,
  lib,
  inputs,
  ...
}: {
  programs.fish = {
    enable = true;

    shellAliases = {
      # Modern replacements
      ll = "lsd -l";
      la = "lsd -la";
      ls = "lsd";
      cat = "bat";
      grep = "rg";
      find = "fd";
      sed = "sd";
      du = "dust";
      df = "duf";
      ps = "procs";
      top = "btm";
      htop = "btm";
      dig = "dog";

      # Git
      g = "git";
      gg = "gitu";
      lg = "lazygit";

      # NixOS
      rebuild = "sudo nixos-rebuild switch --flake .#nixos";
      update = "nix flake update";
      clean = "sudo nix-collect-garbage -d";
      generations = "sudo nix-env --list-generations --profile /nix/var/nix/profiles/system";
    };
  };
}


