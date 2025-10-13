{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.services.k3s-cluster.server;
in
{
  options.services.k3s-cluster.server = {
    enable = mkEnableOption "K3s Server (Master Node)";

    nodeAddress = mkOption {
      type = types.str;
      example = "192.168.2.56";
      description = "IP address of this server node";
    };

    tokenFile = mkOption {
      type = types.path;
      description = "Path to file containing cluster join token";
    };

    kubeconfigPath = mkOption {
      type = types.str;
      default = "/home/biocirc/.config/k3s/kubeconfig";
      description = "Where to write kubeconfig with user permissions";
    };

    clusterCidr = mkOption {
      type = types.str;
      default = "10.42.0.0/16";
      description = "Pod network CIDR (Flannel default)";
    };

    serviceCidr = mkOption {
      type = types.str;
      default = "10.43.0.0/16";
      description = "Service network CIDR";
    };

    nodeLabels = mkOption {
      type = types.listOf types.str;
      default = [ ];
      example = [
        "node-role=master"
        "gpu=true"
      ];
      description = "Node labels in key=value format";
    };

    nodeTaints = mkOption {
      type = types.listOf types.str;
      default = [ ];
      example = [ "node-role=master:NoSchedule" ];
      description = "Node taints in key=value:effect format";
    };

    extraFlags = mkOption {
      type = types.listOf types.str;
      default = [ ];
      description = "Additional K3s server flags";
    };

    tls = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Deploy TLS certificates to Kubernetes secrets";
      };

      localCertFile = mkOption {
        type = types.path;
        default = config.sops.secrets.local_tls_cert.path;
        description = "Path to local certificate secret (base64 encoded)";
      };

      localKeyFile = mkOption {
        type = types.path;
        default = config.sops.secrets.local_tls_key.path;
        description = "Path to local key secret (base64 encoded)";
      };

      publicCertFile = mkOption {
        type = types.path;
        default = config.sops.secrets.public_tls_cert.path;
        description = "Path to public certificate secret (base64 encoded)";
      };

      publicKeyFile = mkOption {
        type = types.path;
        default = config.sops.secrets.public_tls_key.path;
        description = "Path to public key secret (base64 encoded)";
      };
    };

    traefik = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Configure Traefik with TLS certificates and dashboard";
      };

      publicDomain = mkOption {
        type = types.str;
        example = "yourdomain.com";
        description = "Public domain for named TLS store (without wildcard)";
      };

      dashboard = {
        enable = mkOption {
          type = types.bool;
          default = true;
          description = "Enable Traefik dashboard on local domain with BasicAuth";
        };

        domain = mkOption {
          type = types.str;
          default = "traefik.local";
          description = "Domain for Traefik dashboard (should be *.local for self-signed cert)";
        };

        passwordFile = mkOption {
          type = types.path;
          default = config.sops.secrets.traefik_dashboard_pw.path;
          description = "Path to plain text password file for BasicAuth";
        };
      };
    };

  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = !config.services.k3s-cluster.agent.enable;
        message = "K3s server and agent cannot run on the same node";
      }
    ];

    services.k3s = {
      enable = true;
      role = "server";
      inherit (cfg) tokenFile;

      extraFlags = lib.concatStringsSep " " (
        [
          "--node-ip=${cfg.nodeAddress}"
          "--cluster-cidr=${cfg.clusterCidr}"
          "--service-cidr=${cfg.serviceCidr}"
          "--write-kubeconfig=${cfg.kubeconfigPath}"
          "--write-kubeconfig-mode=644"
          "--flannel-backend=vxlan"
        ]
        ++ (map (label: "--node-label=${label}") cfg.nodeLabels)
        ++ (map (taint: "--node-taint=${taint}") cfg.nodeTaints)
        ++ cfg.extraFlags
      );
    };

    systemd.tmpfiles.rules = [
      "d /var/lib/rancher/k3s/server/manifests 0755 root root -"
      "d ${dirOf cfg.kubeconfigPath} 0755 biocirc users -"
    ];


    # Traefik HelmChartConfig
    environment.etc."rancher/k3s/server/manifests/traefik-config.yaml" = mkIf cfg.traefik.enable {
      text = ''
        apiVersion: helm.cattle.io/v1
        kind: HelmChartConfig
        metadata:
          name: traefik
          namespace: kube-system
        spec:
          valuesContent: |-
            ports:
              web:
                port: 80
                exposedPort: 80
                redirectTo:
                  port: websecure
              websecure:
                port: 443
                exposedPort: 443
                tls:
                  enabled: true
            
            tls:
              stores:
                default:
                  defaultCertificate:
                    secretName: local-tls-cert
                public:
                  defaultCertificate:
                    secretName: public-tls-cert
              
              options:
                default:
                  minVersion: VersionTLS12
                  sniStrict: true
                  cipherSuites:
                    - TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256
                    - TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384
                    - TLS_ECDHE_RSA_WITH_CHACHA20_POLY1305
            
            ${optionalString cfg.traefik.dashboard.enable ''
            dashboard:
              enabled: true
            
            ingressRoute:
              dashboard:
                enabled: true
                matchRule: Host(`${cfg.traefik.dashboard.domain}`)
                entryPoints:
                  - websecure
                tls: {}
                middlewares:
                  - name: dashboard-auth
            ''}
            
            additionalArguments:
              - "--entrypoints.websecure.http.middlewares=hsts@file"
            
            providers:
              file:
                content: |
                  [http.middlewares.hsts.headers]
                    stsSeconds = 31536000
                    stsIncludeSubdomains = true
                    stsPreload = true
      '';
      mode = "0644";
      user = "root";
      group = "root";
    };
    # Traefik Dashboard BasicAuth Middleware
    environment.etc."rancher/k3s/server/manifests/traefik-dashboard-middleware.yaml" = mkIf cfg.traefik.dashboard.enable {
      text = ''
        apiVersion: traefik.io/v1alpha1
        kind: Middleware
        metadata:
          name: dashboard-auth
          namespace: kube-system
        spec:
          basicAuth:
            secret: traefik-dashboard-auth
      '';
      mode = "0644";
      user = "root";
      group = "root";
    };


    systemd.services.k3s.serviceConfig = {
      ExecStartPost = "${pkgs.coreutils}/bin/chown biocirc:users ${cfg.kubeconfigPath}";
    };

    environment.systemPackages = with pkgs; [
      k3s
      kubectl
      kubernetes-helm
    ];

    

    
    environment.variables = {
      KUBECONFIG = cfg.kubeconfigPath;
    };

    networking.firewall = {
      allowedTCPPorts = [
        6443
        10250
      ];
      allowedUDPPorts = [
        8472
      ];
      trustedInterfaces = [ "flannel.1" ];
    };

    # TLS Certificate Deployment
    systemd.services.k3s-deploy-tls-certs = mkIf cfg.tls.enable {
      description = "Deploy TLS certificates to K3s";
      after = [ "k3s.service" ];
      requires = [ "k3s.service" ];
      wantedBy = [ "multi-user.target" ];

      environment = {
        KUBECONFIG = "/etc/rancher/k3s/k3s.yaml";
      };

      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        Restart = "on-failure";
        RestartSec = "30s";
      };

      preStart = "${pkgs.coreutils}/bin/sleep 10";

      script = ''
        set -euo pipefail

        TMPDIR=$(${pkgs.coreutils}/bin/mktemp -d)
        trap "${pkgs.coreutils}/bin/rm -rf $TMPDIR" EXIT

        echo "Deploying local TLS certificate..."
        ${pkgs.coreutils}/bin/cat ${cfg.tls.localCertFile} | ${pkgs.coreutils}/bin/base64 -d > "$TMPDIR/local.crt"
        ${pkgs.coreutils}/bin/cat ${cfg.tls.localKeyFile} | ${pkgs.coreutils}/bin/base64 -d > "$TMPDIR/local.key"

        ${pkgs.kubectl}/bin/kubectl create secret tls local-tls-cert \
          --cert="$TMPDIR/local.crt" \
          --key="$TMPDIR/local.key" \
          --namespace=kube-system \
          --dry-run=client -o yaml | ${pkgs.kubectl}/bin/kubectl apply -f -

        echo "Deploying public TLS certificate..."
        ${pkgs.coreutils}/bin/cat ${cfg.tls.publicCertFile} | ${pkgs.coreutils}/bin/base64 -d > "$TMPDIR/public.crt"
        ${pkgs.coreutils}/bin/cat ${cfg.tls.publicKeyFile} | ${pkgs.coreutils}/bin/base64 -d > "$TMPDIR/public.key"

        ${pkgs.kubectl}/bin/kubectl create secret tls public-tls-cert \
          --cert="$TMPDIR/public.crt" \
          --key="$TMPDIR/public.key" \
          --namespace=kube-system \
          --dry-run=client -o yaml | ${pkgs.kubectl}/bin/kubectl apply -f -

        echo "TLS certificates deployed successfully"
      '';
    };
    # Dashboard BasicAuth Secret Deployment
    systemd.services.k3s-deploy-dashboard-auth = mkIf cfg.traefik.dashboard.enable {
      description = "Deploy Traefik Dashboard BasicAuth Secret";
      after = [ 
        "k3s.service" 
        "k3s-deploy-tls-certs.service" 
      ];
      requires = [ "k3s.service" ];
      wantedBy = [ "multi-user.target" ];
      
      path = [ pkgs.apacheHttpd pkgs.kubectl ];
      
      environment = {
        KUBECONFIG = "/etc/rancher/k3s/k3s.yaml";
      };
      
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        Restart = "on-failure";
        RestartSec = "30s";
      };
      
      preStart = "${pkgs.coreutils}/bin/sleep 10";
      
      script = ''
        set -euo pipefail
        
        echo "Generating htpasswd for dashboard..."
        PASSWORD=$(${pkgs.coreutils}/bin/cat ${cfg.traefik.dashboard.passwordFile})
        HTPASSWD=$(${pkgs.apacheHttpd}/bin/htpasswd -nb admin "$PASSWORD")
        
        echo "Deploying BasicAuth secret..."
        ${pkgs.kubectl}/bin/kubectl create secret generic traefik-dashboard-auth \
          --from-literal=users="$HTPASSWD" \
          --namespace=kube-system \
          --dry-run=client -o yaml | ${pkgs.kubectl}/bin/kubectl apply -f -
        
        echo "Dashboard auth secret deployed"
      '';
    };

  # Traefik Configuration Trigger
      systemd.services.k3s-traefik-restart = mkIf cfg.traefik.enable {
        description = "Restart Traefik pods to apply new configuration";
        after = [ 
          "k3s.service" 
          "k3s-deploy-tls-certs.service"
        ] ++ optional cfg.traefik.dashboard.enable "k3s-deploy-dashboard-auth.service";
        requires = [ "k3s.service" ];
        wantedBy = [ "multi-user.target" ];
      
        path = [ pkgs.kubectl pkgs.coreutils ];
      
        environment = {
          KUBECONFIG = "/etc/rancher/k3s/k3s.yaml";
        };
      
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
          Restart = "on-failure";
          RestartSec = "30s";
        };
      
        preStart = "${pkgs.coreutils}/bin/sleep 15";
      
        script = ''
          set -euo pipefail
        
          echo "Waiting for Traefik deployment to be ready..."
          for i in {1..30}; do
            if ${pkgs.kubectl}/bin/kubectl get deployment traefik -n kube-system &>/dev/null; then
              echo "Traefik deployment found"
              break
            fi
            if [ $i -eq 30 ]; then
              echo "Timeout waiting for Traefik deployment"
              exit 1
            fi
            ${pkgs.coreutils}/bin/sleep 2
          done
        
          echo "Restarting Traefik pods to apply configuration..."
          ${pkgs.kubectl}/bin/kubectl rollout restart deployment/traefik -n kube-system
        
          echo "Waiting for rollout to complete..."
          ${pkgs.kubectl}/bin/kubectl rollout status deployment/traefik -n kube-system --timeout=5m
        
          echo "Traefik restart completed successfully"
        '';
      };
  };
}
