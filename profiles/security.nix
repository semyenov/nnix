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

  # USB device policy - disabled by default as it can cause issues
  # Enable per-host if needed with proper rules
  services.usbguard.enable = lib.mkDefault false;

  # Auditing
  security.auditd.enable = lib.mkDefault true;
}


