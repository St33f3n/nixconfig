# Auto-generated using compose2nix v0.3.1.
{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkIf;
  cfg = config.services.doc_safe;
in
{
  # Runtime
  # Calibre Web
  "calibre-web" = mkIf cfg.calibreWeb.enable {
    image = "lscr.io/linuxserver/calibre-web:latest";
    environment = {
      "DOCKER_MODS" = "linuxserver/mods:universal-calibre";
      "OAUTHLIB_RELAX_TOKEN_SCOPE" = "1";
      "PGID" = toString cfg.calibreWeb.credentials.pgid;
      "PUID" = toString cfg.calibreWeb.credentials.puid;
      "TZ" = "Europe/Berlin";
    };
    volumes = [
      "${cfg.dataDir}/EBooks:/books/raw:rw"
      "${cfg.dataDir}/calibre-web/config:/config:rw"
    ];
    ports = [ "${toString cfg.calibreWeb.port}:8083/tcp" ];
    log-driver = cfg.docker.logDriver;
    extraOptions = [
      "--network-alias=calibre-web"
      "--network=${cfg.networkName}"
    ];
  };
  # Picsur
  "picsur" = mkIf cfg.picsur.enable {
    image = "ghcr.io/caramelfur/picsur:latest";
    environment = {
      "PICSUR_DB_HOST" = "picsurdb";
      "PICSUR_DB_PORT" = "5432";
      "PICSUR_DB_USERNAME" = cfg.picsur.database.user;
      "PICSUR_DB_PASSWORD" = cfg.picsur.database.password;
      "PICSUR_DB_DATABASE" = cfg.picsur.database.name;
      "PICSUR_ADMIN_PASSWORD" = cfg.picsur.adminPassword;
      "PICSUR_MAX_FILE_SIZE" = toString cfg.picsur.maxFileSize;
    };
    ports = [ "${toString cfg.picsur.port}:8080" ];
    log-driver = cfg.docker.logDriver;
    dependsOn = [ "picsurdb" ];
    extraOptions = [
      "--network-alias=picsur"
      "--network=${cfg.networkName}"
    ];
  };

  # Picsur Database
  "picsurdb" = mkIf cfg.picsur.enable {
    image = "postgres:17-alpine";
    environment = {
      "POSTGRES_DB" = cfg.picsur.database.name;
      "POSTGRES_PASSWORD" = cfg.picsur.database.password;
      "POSTGRES_USER" = cfg.picsur.database.user;
      "PGDATA" = "/var/lib/postgresql/data/pgdata";
    };
    volumes = [ "${cfg.dataDir}/picsur-data:/var/lib/postgresql/data:rw" ];
    ports = [ "${toString cfg.picsur.database.port}:5432" ];
    log-driver = cfg.docker.logDriver;
    extraOptions = [
      "--network-alias=picsurdb"
      "--network=${cfg.networkName}"
      "--health-cmd=pg_isready"
      "--health-interval=10s"
      "--health-timeout=5s"
      "--health-retries=5"
      "--memory=512m"
      "--memory-swap=1g"
    ];
  };

  # JupyterLab
  "jupyterlab" = mkIf cfg.jupyterLab.enable {
    image = "quay.io/jupyter/pytorch-notebook:latest";
    environment = {
      "CHOWN_HOME" = "yes";
      "JUPYTER_TOKEN" = cfg.jupyterLab.token;
      "NB_GID" = "100";
      "NB_UID" = toString cfg.jupyterLab.uid;
      "NB_USER" = cfg.jupyterLab.user;
    };
    volumes = [ "${cfg.dataDir}/notebooks:/home/jupyternb:rw" ];
    ports = [ "${toString cfg.jupyterLab.port}:8888/tcp" ];
    user = "root";
    log-driver = cfg.docker.logDriver;
    extraOptions = [
      "--network-alias=jupyterlab"
      "--network=${cfg.networkName}"
    ];
  };

  "mealie" = mkIf cfg.mealie.enable {
    image = "ghcr.io/mealie-recipes/mealie:latest";
    environment = {
      "ALLOW_SIGNUP" = toString cfg.mealie.allowSignup;
      "BASE_URL" = cfg.mealie.baseUrl;
      "MAX_WORKERS" = "1";
      "PGID" = toString 100;
      "PUID" = toString 1000;
      "TZ" = "Europe/Berlin";
      "WEB_CONCURRENCY" = "1";
    };
    volumes = [ "${cfg.dataDir}/mealie:/app/data:rw" ];
    ports = [ "${toString cfg.mealie.port}:9000/tcp" ];
    log-driver = cfg.docker.logDriver;
    extraOptions = [
      "--network-alias=mealie"
      "--network=${cfg.networkName}"
    ];
  };
  # Wiki.js
  "wikijs" = mkIf cfg.wikiJs.enable {
    image = "ghcr.io/requarks/wiki:latest";
    environment = {
      "DB_HOST" = "wiki-db";
      "DB_NAME" = cfg.wikiJs.database.name;
      "DB_PASS" = cfg.wikiJs.database.password;
      "DB_PORT" = "5432";
      "DB_TYPE" = "postgres";
      "DB_USER" = cfg.wikiJs.database.user;
    };
    ports = [ "${toString cfg.wikiJs.port}:3000/tcp" ];
    dependsOn = [ "wiki-db" ];
    log-driver = cfg.docker.logDriver;
    extraOptions = [
      "--network-alias=wiki"
      "--network=${cfg.networkName}"
    ];
  };

  # Wiki.js Database
  "wiki-db" = mkIf cfg.wikiJs.enable {
    image = "postgres:15-alpine";
    environment = {
      "POSTGRES_DB" = cfg.wikiJs.database.name;
      "POSTGRES_PASSWORD" = cfg.wikiJs.database.password;
      "POSTGRES_USER" = cfg.wikiJs.database.user;
    };
    volumes = [ "${cfg.dataDir}/wikijs/db:/var/lib/postgresql/data:rw" ];
    log-driver = cfg.docker.logDriver;
    extraOptions = [
      "--network-alias=wiki-db"
      "--network=${cfg.networkName}"
    ];
  };

  # Wallabag
  "wallabag" = mkIf cfg.wallabag.enable {
    image = "wallabag/wallabag";
    environment = {
      "MYSQL_ROOT_PASSWORD" = cfg.wallabag.database.rootPassword;
      "SYMFONY__ENV__DATABASE_CHARSET" = "utf8mb4";
      "SYMFONY__ENV__DATABASE_DRIVER" = "pdo_mysql";
      "SYMFONY__ENV__DATABASE_HOST" = "walladb";
      "SYMFONY__ENV__DATABASE_NAME" = cfg.wallabag.database.name;
      "SYMFONY__ENV__DATABASE_PASSWORD" = cfg.wallabag.database.password;
      "SYMFONY__ENV__DATABASE_PORT" = "3306";
      "SYMFONY__ENV__DATABASE_TABLE_PREFIX" = ''"wallabag_"'';
      "SYMFONY__ENV__DATABASE_USER" = cfg.wallabag.database.user;
      "SYMFONY__ENV__DOMAIN_NAME" = cfg.wallabag.domain;
      "SYMFONY__ENV__FROM_EMAIL" = cfg.wallabag.email.from;
      "SYMFONY__ENV__MAILER_DSN" = cfg.wallabag.email.mailerDsn;
      "SYMFONY__ENV__SERVER_NAME" = ''"${cfg.wallabag.serverName}"'';
    };
    volumes = [
      "${cfg.dataDir}/wallabag/images:/var/www/wallabag/web/assets/images:rw"
    ];
    ports = [ "${toString cfg.wallabag.port}:80/tcp" ];
    dependsOn = [
      "doc_safe-redis"
      "doc_safe-walladb"
    ];
    log-driver = cfg.docker.logDriver;
    extraOptions = [
      "--network-alias=wallabag"
      "--network=${cfg.networkName}"
    ];
  };

  # Wallabag Database
  "doc_safe-walladb" = mkIf cfg.wallabag.enable {
    image = "mariadb";
    environment = {
      "MYSQL_ROOT_PASSWORD" = cfg.wallabag.database.rootPassword;
    };
    volumes = [ "${cfg.dataDir}/wallabag/data:/var/lib/mysql:rw" ];
    log-driver = cfg.docker.logDriver;
    extraOptions = [
      "--network-alias=walladb"
      "--network=${cfg.networkName}"
    ];
  };

  # Redis
  "doc_safe-redis" = mkIf cfg.wallabag.enable {
    image = "redis:alpine";
    log-driver = cfg.docker.logDriver;
    extraOptions = [
      ''--health-cmd=["redis-cli", "ping"]''
      "--health-interval=20s"
      "--health-timeout=3s"
      "--network-alias=redis"
      "--network=${cfg.networkName}"
    ];
  };

  # Trilium Notes
  "trilium-notes" = mkIf cfg.trilium.enable {
    image = "triliumnext/notes:stable";
    volumes = [ "${cfg.dataDir}/trilium:/home/node/trilium-data:rw" ];
    ports = [ "${toString cfg.trilium.port}:8080/tcp" ];
    log-driver = cfg.docker.logDriver;
    extraOptions = [
      "--network-alias=trilium-notes"
      "--network=${cfg.networkName}"
    ];
  };
}
