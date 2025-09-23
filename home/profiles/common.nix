{
  config,
  pkgs,
  lib,
  inputs,
  ...
}: {
  home.packages = with pkgs; [
    gopass
    gopass-jsonapi
    nekoray
  ];
}
