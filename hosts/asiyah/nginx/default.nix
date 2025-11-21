{ pkgs, lib, config, ... }:
let
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
    package = pkgs.nginxQuic.override {
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

    enableQuicBPF = true;

    logError = "/var/log/nginx/error.log";

    appendHttpConfig = ''
      set_real_ip_from ${config.gradient.const.wireguard.addresses.gradientnet.gradientnet}/24;
      real_ip_header proxy_protocol;
      real_ip_header X-Forwarded-For;
      real_ip_recursive on;

      map $username $xusername {
        ~^(\w+)@identity.gradient.moe $1;
        default "";
      } 
    '';
  };

  security.acme = {
    acceptTerms = true;
    defaults = {
      email = "gradientvera+acme@outlook.com";
      dnsResolver = "1.1.1.1:53";
      # dnsProvider = "cloudflare"; # Apparently this default doesn't work lmao
      credentialFiles."CF_DNS_API_TOKEN_FILE" = config.sops.secrets.acme-cf-token.path;
    };
  };

  networking.firewall.allowedTCPPorts = with ports; [
    nginx nginx-ssl nginx-proxy nginx-ssl-proxy
  ];
  networking.firewall.allowedUDPPorts = with ports; [
    nginx nginx-ssl nginx-proxy nginx-ssl-proxy
  ];

}