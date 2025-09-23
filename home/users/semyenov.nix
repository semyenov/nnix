{
  config,
  pkgs,
  lib,
  inputs,
  ...
}: {
  imports = [
    ../profiles/cli-tools.nix
    ../profiles/development.nix
    ../profiles/productivity.nix
    ../profiles/sysadmin.nix
  ];

  home = {
    username = "semyenov";
    homeDirectory = "/home/semyenov";
    stateVersion = "25.05";
  };

  programs.home-manager.enable = true;

  programs.git = {
    enable = true;
    userName = "Alexander Semyenov";
    userEmail = "semyenov@hotmail.com";
    extraConfig = {
      init.defaultBranch = "main";
      core.editor = "nvim";
      pull.rebase = false;
      push.autoSetupRemote = true;
      diff.colorMoved = "default";
      merge.conflictstyle = "diff3";
    };
  };
}
