{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.profiles.users;
in {
  options.profiles.users = {
    enable =
      mkEnableOption "User management"
      // {
        default = true;
      };

    primaryUser = mkOption {
      type = types.str;
      default = "semyenov";
      description = "Primary user name";
    };
  };

  config = mkIf cfg.enable {
    # User groups
    users.groups.${cfg.primaryUser} = {
      gid = 1000;
    };

    # User account
    users.users.${cfg.primaryUser} = {
      isNormalUser = true;
      uid = 1000;
      group = cfg.primaryUser;
      home = "/home/${cfg.primaryUser}";
      description = "Alexander Semyenov";
      extraGroups = [
        "wheel"
        "networkmanager"
        "audio"
        "video"
        "docker"
        "libvirtd"
      ];
      shell = pkgs.fish;
    };
  };
}
