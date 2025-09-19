{ config, lib, pkgs, ... }:

{
  # Baseline system settings common to most hosts

  nixpkgs.config.allowUnfree = true;

  networking.networkmanager.enable = true;

  # Nix settings and hygiene
  nix = {
    package = pkgs.nixVersions.stable;

    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      auto-optimise-store = true;
      substituters = [
        "https://cache.nixos.org"
        "https://nix-community.cachix.org"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
      trusted-users = [ "root" "@wheel" ];
    };

    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };

    optimise.automatic = true;
  };

  # Firmware updates and tmp cleanup
  services.fwupd.enable = true;
  boot.tmp.cleanOnBoot = true;

  # Enable shells
  programs.fish.enable = true;
}


