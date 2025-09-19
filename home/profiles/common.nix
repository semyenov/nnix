{ config, pkgs, lib, inputs, ... }:

{
  # Base Home Manager settings common to the user
  programs.home-manager.enable = true;

  # Direnv with nix support
  programs.direnv = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };
}
