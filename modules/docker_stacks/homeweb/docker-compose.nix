{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkIf;
  cfg = config.services.homeweb;
in
{
  # Homepage
  "homepage" = mkIf cfg.homepage.enable {
    image = "ghcr.io/gethomepage/homepage:latest";
    environment = {
      "PUID" = "1000";
      "GUID" = "1000";
    };
    volumes = [
      "${cfg.dataDir}/homepage:/app/config"
      "/var/run/docker.sock:/var/run/docker.sock:ro"
    ];
    ports = [ "${toString cfg.homepage.port}:3000/tcp" ];
    log-driver = cfg.docker.logDriver;
    extraOptions = [
      "--network-alias=homepage"
      "--network=${cfg.networkName}"
      "--security-opt=no-new-privileges"
    ];
  };

  #Homebox
  "homebox" = mkIf cfg.homebox.enable {
    image = "ghcr.io/sysadminsmedia/homebox:latest";
    environment = {
      "HBOX_LOG_LEVEL" = "info";
      "HBOX_LOG_FORMAT" = "text";
      "HBOX_WEB_MAX_UPLOAD_SIZE" = toString cfg.homebox.max_upload_size;
      "HBOX_MAILER_HOST" = cfg.homebox.mail_server.url;
      "HBOX_MAILER_PORT" = toString cfg.homebox.mail_server.port;
      "HBOX_MAILER_USERNAME" = cfg.homebox.mail_server.user;
      "HBOX_MAILER_PASSWORD" = cfg.homebox.mail_server.user_pwd;
      "HBOX_MAILER_FROM" = cfg.homebox.mail_server.e_mail;
    };
    volumes = [ "${cfg.dataDir}/homebox:/data" ];
    ports = [ "${toString cfg.homebox.port}:7745/tcp" ];
    log-driver = cfg.docker.logDriver;
  };

  #wallos
  "wallos" = mkIf cfg.wallos.enable {
    image = "bellamy/wallos:latest";
    environment = {
      "TZ" = "Europe/Berlin";
    };
    volumes = [
      "${cfg.dataDir}/wallos/db:/var/www/html/db"
      "${cfg.dataDir}/wallos/logos:/var/www/html/images/uploads/logos"
    ];
    ports = [ "${toString cfg.wallos.port}:80/tcp" ];
    log-driver = cfg.docker.logDriver;
  };
}
