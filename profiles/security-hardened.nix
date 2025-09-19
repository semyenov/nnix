{ config, lib, pkgs, ... }:

{
  imports = [ ../modules/system/security.nix ];

  modules.system.security.enable = true;

  # Common secure defaults
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
    };
  };

  # USB device policy
  services.usbguard.enable = lib.mkDefault true;

  # Auditing
  security.auditd.enable = lib.mkDefault true;
}


