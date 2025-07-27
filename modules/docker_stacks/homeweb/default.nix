{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.services.homeweb;

  # Hilfsfunktion zur Generierung der Standard-Service-Konfiguration
  mkDockerService =
    name: restartPolicy: extraConfig:
    {
      serviceConfig = {
        Restart = lib.mkOverride 90 (if restartPolicy then "always" else "no");
        RestartMaxDelaySec = lib.mkOverride 90 "1m";
        RestartSec = lib.mkOverride 90 "10s";
        RestartSteps = lib.mkOverride 90 9;
      };
      after = [ "docker-network-${cfg.networkName}.service" ];
      requires = [ "docker-network-${cfg.networkName}.service" ];
      partOf = [ "docker-compose-homeweb-root.target" ];
      wantedBy = mkIf cfg.docker.autoStart [ "docker-compose-homeweb-root.target" ];
    }
    // extraConfig;
in
{
  options.services.homeweb = {
    enable = mkEnableOption "homeweb";
    dataDir = mkOption {
      type = types.str;
      default = "/home/steefen/storage";
      description = "Basis-Verzeichnis für alle Container-Daten";
    };

    networkName = mkOption {
      type = types.str;
      default = "homeweb_default";
      description = "Name des Docker-Netzwerks";
    };

    homepage = {
      enable = mkEnableOption "homepage";
      port = mkOption {
        type = types.port;
        default = 3000;
        description = "Port für Homepage";
      };
    };

    homebox = {
      enable = mkEnableOption "homebox";
      port = mkOption {
        type = types.port;
        default = 7745;
        description = "Port für Homebox";
      };
      max_upload_size = mkOption {
        type = types.int;
        default = 10;
        description = "Max web upload";
      };
      mail_server = {
        url = mkOption {
          type = types.str;
          default = "";
          description = "Email - Host";
        };
        port = mkOption {
          type = types.int;
          default = 587;
          description = "Port for Email-Host";
        };

        user = mkOption {
          type = types.str;
          default = "";
          description = "Email - User";
        };

        user_pwd = mkOption {
          type = types.str;
          default = "";
          description = "Email - PWD";
        };

        e_mail = mkOption {
          type = types.str;
          default = "";
          description = "Email";
        };
      };
    };

    wallos = {
      enable = mkEnableOption "wallos";
      port = mkOption {
        type = types.port;
        default = 8282;
        description = "Port für wallos";
      };
    };

    docker = {
      autoStart = mkOption {
        type = types.bool;
        default = true;
        description = "Container automatisch beim Systemstart starten";
      };
      logDriver = mkOption {
        type = types.enum [
          "journald"
          "json-file"
          "none"
        ];
        default = "journald";
        description = "Standard Log-Driver für Container";
      };
    };
  };

  config = mkIf cfg.enable {
    virtualisation.oci-containers.containers = import ./docker-compose.nix { inherit config lib pkgs; };

    systemd.services = mkMerge [
      # Netzwerk-Service
      {
        "docker-network-${cfg.networkName}" = {
          path = [ pkgs.docker ];
          serviceConfig = {
            Type = "oneshot";
            RemainAfterExit = true;
            ExecStop = "docker network rm -f ${cfg.networkName}";
          };
          script = ''
            docker network inspect ${cfg.networkName} || docker network create ${cfg.networkName}
          '';
          partOf = [ "docker-compose-homeweb-root.target" ];
          wantedBy = [ "docker-compose-homeweb-root.target" ];
        };
      }

      # Homepage
      (mkIf cfg.homepage.enable {
        "docker-homepage" = mkDockerService "homepage" true { };
      })

      # Wallos
      (mkIf cfg.wallos.enable {
        "docker-wallos" = mkDockerService "homewallos" true { };
      })

      # Homebox
      (mkIf cfg.homebox.enable {
        "docker-homebox" = mkDockerService "homebox" true { };
      })
    ];

    # Root target
    systemd.targets."docker-compose-homeweb-root" = {
      description = "Root target für homeweb Docker-Compose Stack";
      wantedBy = [ "multi-user.target" ];
    };
  };
}
