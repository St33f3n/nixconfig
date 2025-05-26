{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.services.infrastructure;

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
      partOf = ["docker-compose-infrastructure-root.target"];
      wantedBy =
        mkIf cfg.docker.autoStart
        ["docker-compose-infrastructure-root.target"];
    }
    // extraConfig;
in {
  options.services.infrastructure = {
    enable = mkEnableOption "infrastructure";
    dataDir = mkOption {
      type = types.str;
      default = "/home/steefen/storage";
      description = "Basis-Verzeichnis für alle Container-Daten";
    };

    networkName = mkOption {
      type = types.str;
      default = "infrastructure_default";
      description = "Name des Docker-Netzwerks";
    };

    mail_bridge = {
      enable = mkEnableOption "mail_bridge";
      smtp_port = mkOption {
        type = types.port;
        default = 12025;
        description = "Port für SMTP";
      };
      imap_port = mkOption {
        type = types.port;
        default = 12143;
        description = "Port für IMAP";
      };
    };

    rustdesk = {
      enable = mkEnableOption "rustdesk";
      domain = mkOption {
        type = types.str;
        default = "dumy.com";
        description = "Domain for Rustdesk Node";
      };
      key = mkOption {
        type = types.str;
        default = "_";
        description = "Schlüssel für RustDesk Server";
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
          partOf = ["docker-compose-infrastructure-root.target"];
          wantedBy = ["docker-compose-infrastructure-root.target"];
        };
      }

      (mkIf cfg.mail_bridge.enable {
        "mail_bridge" = mkDockerService "mail_bridge" true {};
      })

      (mkIf cfg.rustdesk.enable {
        "docker-rustdesk-hbbr" = mkDockerService "rustdesk-hbbr" true {};
        "docker-rustdesk-hbbs" = mkDockerService "rustdesk-hbbs" true {
          after = [
            "docker-network-${cfg.networkName}.service"
            "docker-rustdesk-hbbr.service"
          ];
          requires = [
            "docker-network-${cfg.networkName}.service"
            "docker-rustdesk-hbbr.service"
          ];
        };
      })
    ];

    # Root target
    systemd.targets."docker-compose-infrastructure-root" = {
      description = "Root target für infrastructure Docker-Compose Stack";
      wantedBy = ["multi-user.target"];
    };
  };
}
