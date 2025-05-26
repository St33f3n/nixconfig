{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf;
  cfg = config.services.doc_safe;
in {
  # Mail Bridge
  "mail_bridge" = mkIf cfg.protonmail.enable {
    image = "ghcr.io/videocurio/proton-mail-bridge:latest";
    volumes = ["${cfg.dataDir}/protonmail:/root:rw"];
    ports = [
      "${toString cfg.protonmail.smtp_port}:25/tcp"
      "${toString cfg.protonmail.imap_port}:143/tcp"
    ];
    log-driver = cfg.docker.logDriver;
    extraOptions = ["--network-alias=mail-bridge" "--network=${cfg.networkName}"];
  };

  # RustDesk HBBS (Server)
  "rustdesk-hbbs" = mkIf cfg.rustdesk.enable {
    image = "rustdesk/rustdesk-server:latest";
    volumes = ["${cfg.dataDir}/rustdesk/hbbs:/root:rw"];
    ports = [
      "21115:21115/tcp"
      "21116:21116/tcp"
      "21116:21116/udp"
      "21118:21118/tcp"
    ];
    command = "hbbs -r ${cfg.rustdesk.domain}:${
      toString cfg.rustdesk.hbbrPort1
    } -k ${cfg.rustdesk.key}";
    log-driver = cfg.docker.logDriver;
    extraOptions = ["--network-alias=rustdesk-hbbs" "--network=${cfg.networkName}"];
    dependsOn = ["rustdesk-hbbr"];
  };

  # RustDesk HBBR (Relay)
  "rustdesk-hbbr" = mkIf cfg.rustdesk.enable {
    image = "rustdesk/rustdesk-server:latest";
    volumes = ["${cfg.dataDir}/rustdesk/hbbr:/root:rw"];
    ports = ["21117:21117/tcp" "21119:21119/tcp"];
    command = "hbbr -k ${cfg.rustdesk.key}";
    log-driver = cfg.docker.logDriver;
    extraOptions = ["--network-alias=rustdesk-hbbr" "--network=${cfg.networkName}"];
  };
}
