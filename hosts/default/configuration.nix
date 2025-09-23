{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    ../../profiles
  ];

  # System packages (minimal - most packages in home-manager)
  environment.systemPackages = with pkgs; [
    gopass
    gopass-jsonapi
    nekoray
  ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken.
  system.stateVersion = "25.05";
}
