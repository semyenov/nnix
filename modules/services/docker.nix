{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.services.docker;
in
{
  options.modules.services.docker = {
    enable = mkEnableOption "Docker container runtime";
    
    enableOnBoot = mkOption {
      type = types.bool;
      default = true;
      description = "Start Docker daemon on boot";
    };
    
    enableNvidia = mkOption {
      type = types.bool;
      default = false;
      description = "Enable NVIDIA GPU support in Docker (uses hardware.nvidia-container-toolkit)";
    };
    
    storageDriver = mkOption {
      type = types.enum [ "overlay2" "devicemapper" "btrfs" "zfs" ];
      default = "overlay2";
      description = "Docker storage driver to use";
    };
    
    dockerComposePackage = mkOption {
      type = types.package;
      default = pkgs.docker-compose;
      description = "Docker Compose package to use";
    };
    
    users = mkOption {
      type = types.listOf types.str;
      default = [ ];
      description = "Users to add to the docker group";
    };
  };

  config = mkMerge [
    (mkIf cfg.enable {
      # Enable Docker
      virtualisation.docker = {
        enable = true;
        enableOnBoot = cfg.enableOnBoot;
        storageDriver = cfg.storageDriver;
        
        # Docker daemon settings
        daemon.settings = {
          # Enable experimental features
          experimental = true;
          
          # Logging
          log-driver = "json-file";
          log-opts = {
            max-size = "10m";
            max-file = "3";
          };
          
          # Network settings
          default-address-pools = [
            { base = "172.30.0.0/16"; size = 24; }
            { base = "172.31.0.0/16"; size = 24; }
          ];
          
          # Storage settings
          storage-opts = [
          ] ++ (if cfg.storageDriver == "overlay2" then [
            "overlay2.override_kernel_check=true"
          ] else []);
          
          # Security options
          userns-remap = "default";
          
          # Performance
          max-concurrent-downloads = 10;
          max-concurrent-uploads = 5;
          
          # Registry mirrors (optional)
          registry-mirrors = [ "https://mirror.gcr.io" ];
        };
        
        # Prune old images and containers periodically
        autoPrune = {
          enable = true;
          dates = "weekly";
          flags = [ "--all" "--volumes" ];
        };
      };

      # Add users to docker group
      users.groups.docker.members = cfg.users;

      # Install Docker-related packages
      environment.systemPackages = with pkgs; [
        docker
        cfg.dockerComposePackage
        docker-credential-helpers
        docker-buildx
        dive
        lazydocker
        skopeo
        podman
        buildah
        kubectl
        k9s
        helm
        ctop
        docker-ls
      ];

      # System configuration for Docker
      boot.kernel.sysctl = {
        "net.ipv4.ip_forward" = mkForce 1;
        "net.ipv6.conf.all.forwarding" = mkForce 1;
        "fs.inotify.max_user_watches" = 1048576;
        "fs.inotify.max_user_instances" = 8192;
      };

      # Firewall configuration for Docker
      networking.firewall.trustedInterfaces = [ "docker0" ];

      # Create Docker configuration directory
      systemd.tmpfiles.rules = [
        "d /etc/docker 0755 root root -"
        "d /var/lib/docker 0711 root root -"
      ];

      # Docker daemon service overrides
      systemd.services.docker = {
        serviceConfig = { Restart = "always"; RestartSec = "5s"; };
        after = [ "network-online.target" ];
        wants = [ "network-online.target" ];
      };

      # Helper scripts
      environment.etc."docker/docker-compose.yml.example" = {
        text = ''
          version: '3.8'
          
          services:
            example:
              image: nginx:alpine
              container_name: example-nginx
              ports:
                - "8080:80"
              volumes:
                - ./html:/usr/share/nginx/html:ro
              restart: unless-stopped
              networks:
                - example-network
          
          networks:
            example-network:
              driver: bridge
          
          volumes:
            example-data:
              driver: local
        '';
        mode = "0644";
      };

      # Aliases for Docker commands
      environment.shellAliases = {
        d = "docker";
        dc = "docker-compose";
        dps = "docker ps";
        dpsa = "docker ps -a";
        di = "docker images";
        drm = "docker rm";
        drmi = "docker rmi";
        dlog = "docker logs -f";
        dexec = "docker exec -it";
        dclean = "docker system prune -af --volumes";
        dstop = "docker stop $(docker ps -q)";
        drmall = "docker rm $(docker ps -aq)";
        drmiall = "docker rmi $(docker images -q)";
        dcup = "docker-compose up -d";
        dcdown = "docker-compose down";
        dclogs = "docker-compose logs -f";
        dcrestart = "docker-compose restart";
        dcrebuild = "docker-compose up -d --build";
      };
    })

    (mkIf (cfg.enable && cfg.enableNvidia) {
      hardware.nvidia-container-toolkit.enable = true;
    })
  ];
}