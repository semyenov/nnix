{ config, pkgs, lib, inputs, ... }:

{
  home = {
    username = "semyenov";
    homeDirectory = "/home/semyenov";
    stateVersion = "25.05";
  };

  imports = [
    ../profiles/common.nix
    ../profiles/desktop.nix
    ../profiles/sysadmin.nix
  ];

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


