{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.profiles.shell;
in {
  options.profiles.shell = {
    enable =
      mkEnableOption "Shell configuration and aliases"
      // {
        default = true;
      };
  };

  config = mkIf cfg.enable {
    # Enable Fish shell
    programs.fish.enable = true;

    # Modern CLI aliases
    environment.shellAliases = {
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
      rebuild = "sudo nixos-rebuild switch --flake .#${config.networking.hostName}";
      update = "nix flake update";
      clean = "sudo nix-collect-garbage -d";
      generations = "sudo nix-env --list-generations --profile /nix/var/nix/profiles/system";
    };
  };
}
