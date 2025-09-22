{ config, pkgs, lib, inputs, ... }:

{
  home = {
    username = "semyenov";
    homeDirectory = "/home/semyenov";
    stateVersion = "25.05";
  };

  imports = [
    ../profiles/desktop.nix
    ../profiles/sysadmin.nix
  ];

  programs.home-manager.enable = true;

  programs.direnv = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };

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