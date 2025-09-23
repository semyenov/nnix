{
  config,
  pkgs,
  lib,
  inputs,
  ...
}: {
  programs.fish = {
    enable = true;

    interactiveShellInit = ''
      # Hide direnv log lines, keep user echo output visible
      set -gx DIRENV_LOG_FORMAT ""

      # GnuPG agent environment
      set -gx GPG_TTY (tty)
      set -gx SSH_AUTH_SOCK (gpgconf --list-dirs agent-ssh-socket)
      gpgconf --launch gpg-agent >/dev/null 2>/dev/null
      gpg-connect-agent updatestartuptty /bye >/dev/null 2>/dev/null
    '';

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
      rebuild = "sudo nixos-rebuild switch --flake .#semyenov";
      update = "nix flake update";
      clean = "sudo nix-collect-garbage -d";
      generations = "sudo nix-env --list-generations --profile /nix/var/nix/profiles/system";
    };
  };
}
