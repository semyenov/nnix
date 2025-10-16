{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.sozdev.mkcert;
in {
  options.sozdev.mkcert = {
    enable =
      mkEnableOption "mkcert local CA certificates for HTTPS development"
      // {
        default = true;
      };

    certificatePath = mkOption {
      type = types.path;
      default = "/home/semyenov/Documents/nn/certs/mkcert";
      description = "Path to the mkcert certificate directory";
    };

    installPackage = mkOption {
      type = types.bool;
      default = true;
      description = "Install mkcert package system-wide";
    };
  };

  config = mkIf cfg.enable {
    # Optionally install mkcert tool for generating local certificates
    environment.systemPackages = mkIf cfg.installPackage [
      pkgs.mkcert
    ];

    # Set system-wide environment variable for mkcert CA location
    # This helps tools find the CA certificates
    environment.sessionVariables = {
      CAROOT = toString cfg.certificatePath;
    };

    # Add mkcert root CA to system-wide trusted certificates (only if the file exists)
    # This makes all browsers and system tools trust mkcert-generated certificates
    security.pki.certificateFiles = mkIf (builtins.pathExists "${cfg.certificatePath}/rootCA.pem") [
      "${cfg.certificatePath}/rootCA.pem"
    ];
  };
}
