# machines/neptune/secrets.nix
{ config, ... }:
{
  sops.defaultSopsFile = ./secrets/secrets.yaml;
  sops.defaultSopsFormat = "yaml";
  sops.age.keyFile = "/home/biocirc/.config/sops/age/keys.txt";

  sops.secrets = {
    k3s_token = {
      sopsFile = ./secrets/k3s.yml;
      owner = config.users.users.biocirc.name;
      mode = "0600";
    };

    local_tls_cert = {
      sopsFile = ./secrets/k3s.yml;
      owner = config.users.users.biocirc.name;
      mode = "0600";
    };

    local_tls_key = {
      sopsFile = ./secrets/k3s.yml;
      owner = config.users.users.biocirc.name;
      mode = "0600";
    };

    public_tls_cert = {
      sopsFile = ./secrets/k3s.yml;
      owner = config.users.users.biocirc.name;
      mode = "0600";
    };
    public_tls_key = {
      sopsFile = ./secrets/k3s.yml;
      owner = config.users.users.biocirc.name;
      mode = "0600";
    };

    traefik_dashboard_pw = {
      sopsFile = ./secrets/k3s.yml;
      owner = config.users.users.biocirc.name;
      mode = "0600";
    };
  };
}
