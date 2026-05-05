{ pkgs, lib, config, ... }:
let
  addresses = config.gradient.const.addresses;
  ports = config.gradient.currentHost.ports;
in {

  imports = [
    ./crp3092.nix
    ./gradientnet.nix
    ./gradient-moe.nix
    ./constellation-moe.nix
    ./constellation-homepage.nix
    ./constellation-moe-internal.nix
    ./constellation-moe-oauth2-proxy.nix
  ];

  gradient.nginx.enableQuic = true;
  gradient.nginx.enableBlockAIBots = true;

  services.nginx = {
    enable = true;
    package = pkgs.nginx.override {
      withSlice = true;
    };
    defaultListen = [
      # HTTP
      { addr = "0.0.0.0"; port = ports.nginx; ssl = false; proxyProtocol = false; }
      { addr = "[::]"; port = ports.nginx; ssl = false; proxyProtocol = false; }

      # Proxy Protocol HTTP
      { addr = "0.0.0.0"; port = ports.nginx-proxy; ssl = false; proxyProtocol = true; }
      { addr = "[::]"; port = ports.nginx-proxy; ssl = false; proxyProtocol = true; }

      # HTTPS
      { addr = "0.0.0.0"; port = ports.nginx-ssl; ssl = true; proxyProtocol = false; }
      { addr = "[::]"; port = ports.nginx-ssl; ssl = true; proxyProtocol = false; }

      # HTTPS but for mmproxy-rs
      { addr = "127.0.0.2"; port = ports.nginx-ssl; ssl = true; proxyProtocol = false; }
      { addr = "[::2]"; port = ports.nginx-ssl; ssl = true; proxyProtocol = false; }
    
      # Proxy Protocol HTTPS
      { addr = "0.0.0.0"; port = ports.nginx-ssl-proxy; ssl = true; proxyProtocol = true; }
      { addr = "[::]"; port = ports.nginx-ssl-proxy; ssl = true; proxyProtocol = true; }
    ];

    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;
    recommendedBrotliSettings = true;
    proxyTimeout = "120s";

    resolver.addresses = [
      "127.0.0.1:53"
    ];

    enableQuicBPF = true;

    logError = "/var/log/nginx/error.log";

    prependConfig = ''
      error_log syslog:server=unix:/dev/log;
    '';

    appendHttpConfig = ''
      log_format combinedwithfqdn '$host:$server_port $remote_addr - $remote_user [$time_local] '
                                  '"$request" $status $body_bytes_sent '
                                  '"$http_referer" "$http_user_agent"';

      access_log /var/log/nginx/access.log combinedwithfqdn;
      access_log syslog:server=unix:/dev/log combinedwithfqdn;
      
      set_real_ip_from ${config.gradient.const.wireguard.addresses.gradientnet.gradientnet}/24;
      real_ip_header proxy_protocol;
      real_ip_recursive on;

      map $preferredusername $xusername {
        ~^(\w+)@identity.gradient.moe $1;
        default $preferredusername;
      } 
    '';
  };

  # Keep restarting nginx no matter what
  systemd.services.nginx.startLimitIntervalSec = lib.mkForce 0;
  systemd.services.nginx.startLimitBurst = lib.mkForce 0;
  systemd.services.nginx.serviceConfig.Restart = lib.mkForce "always";

  security.acme = {
    acceptTerms = true;
    defaults = {
      email = "gradientvera+acme@outlook.com";
      dnsResolver = "1.1.1.1:53";
      # dnsProvider = "cloudflare"; # Apparently this default doesn't work lmao
      credentialFiles."CF_DNS_API_TOKEN_FILE" = config.sops.secrets.acme-cf-token.path;
    };
  };

  services.rsync.jobs.briah-acme = {
    sources = [
      config.security.acme.certs."gradient.moe".directory
      config.security.acme.certs."constellation.moe".directory
    ];
    destination = "root@${addresses.briah}:${config.users.users.acme.home}";
    # vera user for SSH to briah, nginx group to access certs
    user = "vera";
    group = "nginx";
    timerConfig = {
      # Every five minutes. A bit overkill but eh.
      OnCalendar = "*:0/5";
      Persistent = true;
    };
    settings = {
      # Syncs recursively, copy permissions and modification times
      archive = true;
      # Create destination folder if needed
      mkpath = true;
      # Delete files on destination that don't exist on the source anymore
      delete = true;
      # Compress data before transfer
      compress = true;
      # Change owner/group on destination (ACME user not available there)
      chown = "nginx:nginx";
      # Set SSH command, fix rsync being unable to find it otherwise
      rsh = "${lib.getExe pkgs.openssh}";
    };
  };


  networking.firewall.allowedTCPPorts = with ports; [
    nginx nginx-ssl nginx-proxy nginx-ssl-proxy
  ];
  networking.firewall.allowedUDPPorts = with ports; [
    nginx nginx-ssl nginx-proxy nginx-ssl-proxy
  ];

}