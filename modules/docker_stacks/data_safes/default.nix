{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.services.doc_safe;

  # Hilfsfunktion zur Generierung der Standard-Service-Konfiguration
  mkDockerService = name: restartPolicy: extraConfig:
    {
      serviceConfig = {
        Restart = lib.mkOverride 90 (
          if restartPolicy
          then "always"
          else "no"
        );
        RestartMaxDelaySec = lib.mkOverride 90 "1m";
        RestartSec = lib.mkOverride 90 "10s";
        RestartSteps = lib.mkOverride 90 9;
      };
      after = ["docker-network-${cfg.networkName}.service"];
      requires = ["docker-network-${cfg.networkName}.service"];
      partOf = ["docker-compose-doc_safe-root.target"];
      wantedBy =
        mkIf cfg.docker.autoStart ["docker-compose-doc_safe-root.target"];
    }
    // extraConfig;
in {
  options.services.doc_safe = {
    enable = mkEnableOption "doc_safe";
    dataDir = mkOption {
      type = types.str;
      default = "/home/steefen/storage";
      description = "Basis-Verzeichnis für alle Container-Daten";
    };

    networkName = mkOption {
      type = types.str;
      default = "doc_safe_default";
      description = "Name des Docker-Netzwerks";
    };

    picsur = {
      enable = mkEnableOption "picsur";

      port = mkOption {
        type = types.port;
        default = 13050;
        description = "Port für den Picsur-Service";
      };

      maxFileSize = mkOption {
        type = types.int;
        default = 128000000;
        description = "Maximale Dateigröße für Uploads in Bytes";
      };

      adminPassword = mkOption {
        type = types.str;
        default = "PRFe74dgukW#so$U^!k@";
        description = "Admin-Passwort für Picsur";
      };

      database = {
        host = mkOption {
          type = types.str;
          default = "picsurdb";
          description = "Hostname der Picsur-Datenbank";
        };

        port = mkOption {
          type = types.port;
          default = 5434;
          description = "Port der Picsur-Datenbank";
        };

        name = mkOption {
          type = types.str;
          default = "picsurdb";
          description = "Name der Picsur-Datenbank";
        };

        user = mkOption {
          type = types.str;
          default = "picsur";
          description = "Datenbankbenutzer für Picsur";
        };

        password = mkOption {
          type = types.str;
          default = "Kr5s*Naz8zTTAt7ijC!P";
          description = "Datenbank-Passwort für Picsur";
        };
      };
    };

    calibreWeb = {
      enable = mkEnableOption "calibre-web";
      port = mkOption {
        type = types.port;
        default = 8083;
        description = "Port für Calibre-Web";
      };
      credentials = {
        puid = mkOption {
          type = types.int;
          default = 1000;
          description = "PUID für Calibre-Web";
        };
        pgid = mkOption {
          type = types.int;
          default = 1000;
          description = "PGID für Calibre-Web";
        };
      };
    };
    trilium = {
      enable = mkEnableOption "trilium";
      port = mkOption {
        type = types.port;
        default = 8888;
        description = "Port für Calibre-Web";
      };
    };

    wikiJs = {
      enable = mkEnableOption "wiki";
      port = mkOption {
        type = types.port;
        default = 6969;
        description = "Port für Wiki.js";
      };
      database = {
        name = mkOption {
          type = types.str;
          default = "wikiJSDB";
          description = "Datenbank Name für Wiki.js";
        };

        password = mkOption {
          type = types.str;
          default = "i0jONQHmtbB7*NL44V8e";
          description = "Datenbank-Passwort für Wiki.js";
        };
        user = mkOption {
          type = types.str;
          default = "wikijs";
          description = "Datenbank-Benutzer für Wiki.js";
        };
      };
    };

    mealie = {
      enable = mkEnableOption "mealie";
      port = mkOption {
        type = types.port;
        default = 9000;
        description = "Port für Mealie";
      };
      baseUrl = mkOption {
        type = types.str;
        default = "https://mealie.organiccircuitlab.com";
        description = "Basis-URL für Mealie";
      };
      allowSignup = mkOption {
        type = types.bool;
        default = true;
        description = "Erlaube neue Registrierungen";
      };
    };

    jupyterLab = {
      enable = mkEnableOption "jupyterlab";
      port = mkOption {
        type = types.port;
        default = 8888;
        description = "Port für JupyterLab";
      };
      uid = mkOption {
        type = types.int;
        default = 1000;
        description = "UID für JupyterLab";
      };
      user = mkOption {
        type = types.str;
        default = "jupyternb";
        description = "UID für JupyterLab";
      };
      token = mkOption {
        type = types.str;
        default = "unknown-long-token-wich-nobody-gets-3332424";
        description = "Zugangstoken für JupyterLab";
      };
    };

    wallabag = {
      enable = mkEnableOption "wallabag";

      port = mkOption {
        type = types.port;
        default = 16700;
        description = "Port für Wallabag";
      };

      database = {
        rootPassword = mkOption {
          type = types.str;
          default = "wallaroot";
          description = "Root-Passwort für die MariaDB-Datenbank";
        };
        name = mkOption {
          type = types.str;
          default = "wallabag";
          description = "Name der Wallabag-Datenbank";
        };
        user = mkOption {
          type = types.str;
          default = "wallabag";
          description = "Datenbankbenutzer für Wallabag";
        };
        password = mkOption {
          type = types.str;
          default = "wallapass";
          description = "Datenbank-Passwort für Wallabag";
        };
      };

      domain = mkOption {
        type = types.str;
        default = "https://wallabag.organiccircuitlab.com";
        description = "Domain-Name für Wallabag";
      };

      email = {
        from = mkOption {
          type = types.str;
          default = "wallabag@organiccircuitlab.com";
          description = "Absender-E-Mail-Adresse für Wallabag";
        };
        mailerDsn = mkOption {
          type = types.str;
          default = "smtp://127.0.0.1";
          description = "SMTP-Konfiguration für Wallabag";
        };
      };

      serverName = mkOption {
        type = types.str;
        default = "Your wallabag instance";
        description = "Name der Wallabag-Instanz";
      };
    };

    docker = {
      autoStart = mkOption {
        type = types.bool;
        default = true;
        description = "Container automatisch beim Systemstart starten";
      };
      logDriver = mkOption {
        type = types.enum ["journald" "json-file" "none"];
        default = "journald";
        description = "Standard Log-Driver für Container";
      };
    };
  };

  config = mkIf cfg.enable {
    virtualisation.oci-containers.containers =
      import ./docker-compose.nix {inherit config lib pkgs;};

    systemd.services = mkMerge [
      # Netzwerk-Service
      {
        "docker-network-${cfg.networkName}" = {
          path = [pkgs.docker];
          serviceConfig = {
            Type = "oneshot";
            RemainAfterExit = true;
            ExecStop = "docker network rm -f ${cfg.networkName}";
          };
          script = ''
            docker network inspect ${cfg.networkName} || docker network create ${cfg.networkName}
          '';
          partOf = ["docker-compose-doc_safe-root.target"];
          wantedBy = ["docker-compose-doc_safe-root.target"];
        };
      }

      # Calibre-Web
      (mkIf cfg.calibreWeb.enable {
        "docker-calibre-web" = mkDockerService "calibre-web" true {};
      })

      # Picsur
      (mkIf cfg.picsur.enable {
        "docker-picsur" = mkDockerService "picsur" true {
          preStart = ''
            # Wait for database to be ready
            for i in $(seq 1 30); do
              if docker exec picsurdb pg_isready -h localhost -U ${cfg.picsur.database.user}; then
                exit 0
              fi
              sleep 2
            done
            exit 1
          '';
          after = [
            "docker-network-${cfg.networkName}.service"
            "docker-picsurdb.service"
          ];
          requires = [
            "docker-network-${cfg.networkName}.service"
            "docker-picsurdb.service"
          ];
          partOf = ["docker-compose-doc_safe-root.target"];
          wantedBy =
            mkIf cfg.docker.autoStart ["docker-compose-doc_safe-root.target"];
        };
        "docker-picsurdb" = mkDockerService "picsurdb" true {
          preStart = ''
            # Ensure database directory exists with correct permissions
            mkdir -p ${cfg.dataDir}/picsur-data/pgdata
            chmod 700 ${cfg.dataDir}/picsur-data/pgdata
          '';
          after = ["docker-network-${cfg.networkName}.service"];
          requires = ["docker-network-${cfg.networkName}.service"];
          partOf = ["docker-compose-doc_safe-root.target"];
          wantedBy =
            mkIf cfg.docker.autoStart ["docker-compose-doc_safe-root.target"];
        };
      })

      # Wallabag
      (mkIf cfg.wallabag.enable {
        "docker-doc_safe-walladb" =
          mkDockerService "doc_safe-walladb" false {};
        "docker-doc_safe-redis" = mkDockerService "doc_safe-redis" false {};
        "docker-wallabag" = mkDockerService "wallabag" false {
          after = [
            "docker-network-${cfg.networkName}.service"
            "docker-doc_safe-redis.service"
            "docker-doc_safe-walladb.service"
          ];
          requires = [
            "docker-network-${cfg.networkName}.service"
            "docker-doc_safe-redis.service"
            "docker-doc_safe-walladb.service"
          ];
        };
      })

      # JupyterLab
      (mkIf cfg.jupyterLab.enable {
        "docker-jupyterlab" = mkDockerService "jupyterlab" true {};
      })

      # Mealie
      (mkIf cfg.mealie.enable {
        "docker-mealie" = mkDockerService "mealie" true {};
      })

      # Wiki.js
      (mkIf cfg.wikiJs.enable {
        "docker-wiki-db" = mkDockerService "wiki-db" true {};
        "docker-wikijs" = mkDockerService "wikijs" true {
          after = [
            "docker-network-${cfg.networkName}.service"
            "docker-wiki-db.service"
          ];
          requires = [
            "docker-network-${cfg.networkName}.service"
            "docker-wiki-db.service"
          ];
        };
      })

      # Trilium
      (mkIf cfg.trilium.enable {
        "docker-trilium-notes" = mkDockerService "trilium-notes" true {};
      })
    ];

    # Root target
    systemd.targets."docker-compose-doc_safe-root" = {
      description = "Root target für doc_safe Docker-Compose Stack";
      wantedBy = ["multi-user.target"];
    };
  };
}
