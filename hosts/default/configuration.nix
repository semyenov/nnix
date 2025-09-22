{ config, lib, pkgs, inputs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../profiles/gnome.nix
    ../../profiles/nvidia.nix
    ../../profiles/docker.nix
    ../../profiles/security.nix
    ../../profiles/optimizations.nix
  ];

  # Boot loader configuration
  boot.loader = {
    systemd-boot.enable = true;
    systemd-boot.configurationLimit = 5;
    efi.canTouchEfiVariables = true;
    timeout = 3;
  };

  # Networking
  networking = {
    hostName = "nixos";
    firewall.enable = true;
    networkmanager.enable = true;
  };

  time.timeZone = "UTC";
  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings = {
      LC_ADDRESS = "en_US.UTF-8";
      LC_IDENTIFICATION = "en_US.UTF-8";
      LC_MEASUREMENT = "en_US.UTF-8";
      LC_MONETARY = "en_US.UTF-8";
      LC_NAME = "en_US.UTF-8";
      LC_NUMERIC = "en_US.UTF-8";
      LC_PAPER = "en_US.UTF-8";
      LC_TELEPHONE = "en_US.UTF-8";
      LC_TIME = "en_US.UTF-8";
    };
  };

  console = { 
    font = "Lat2-Terminus16"; 
    useXkbConfig = true; 
  };

  # Nix settings
  nixpkgs.config.allowUnfree = true;
  
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

  # Services
  services.fwupd.enable = true;
  boot.tmp.cleanOnBoot = true;
  programs.fish.enable = true;

  # Base system packages
  environment.systemPackages = with pkgs; [
  ];

  # User accounts
  users.groups.semyenov = {
    gid = 1000;
  };

  users.users.semyenov = {
    isNormalUser = true;
    uid = 1000;
    group = "semyenov";
    home = "/home/semyenov";
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

  # Shell aliases
  environment.shellAliases = {
    # Modern replacements
    ll = "lsd -l";
    la = "lsd -la";
    ls = "lsd";
    cat = "bat";
    grep = "rg";
    find = "fd";
    sed = "sd";
    du = "dust";
    df = "duf";
    ps = "procs";
    top = "btm";
    htop = "btm";
    dig = "dog";
    
    # Git
    g = "git";
    gg = "gitui";
    lg = "lazygit";
    
    # NixOS
    rebuild = "sudo nixos-rebuild switch --flake .#nixos";
    update = "nix flake update";
    clean = "sudo nix-collect-garbage -d";
    generations = "sudo nix-env --list-generations --profile /nix/var/nix/profiles/system";
  };

  system.stateVersion = "25.05";
}