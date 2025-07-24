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

  gradient.nginx.enableBlockAIBots = true;

  services.nginx = {
    enable = true;
    package = pkgs.nginxStable.override {
      withSlice = true;
    };
    defaultHTTPListenPort = ports.nginx;
    defaultSSLListenPort = ports.nginx-ssl;
    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;
    recommendedBrotliSettings = true;

    logError = "/var/log/nginx/error.log";

    appendHttpConfig = ''
      set_real_ip_from 173.245.48.0/20;
      set_real_ip_from 103.21.244.0/22;
      set_real_ip_from 103.22.200.0/22;
      set_real_ip_from 103.31.4.0/22;
      set_real_ip_from 141.101.64.0/18;
      set_real_ip_from 108.162.192.0/18;
      set_real_ip_from 190.93.240.0/20;
      set_real_ip_from 188.114.96.0/20;
      set_real_ip_from 197.234.240.0/22;
      set_real_ip_from 198.41.128.0/17;
      set_real_ip_from 162.158.0.0/15;
      set_real_ip_from 104.16.0.0/13;
      set_real_ip_from 104.24.0.0/14;
      set_real_ip_from 172.64.0.0/13;
      set_real_ip_from 131.0.72.0/22;
      set_real_ip_from 2400:cb00::/32;
      set_real_ip_from 2606:4700::/32;
      set_real_ip_from 2803:f800::/32;
      set_real_ip_from 2405:b500::/32;
      set_real_ip_from 2405:8100::/32;
      set_real_ip_from 2a06:98c0::/29;
      set_real_ip_from 2c0f:f248::/32;
      real_ip_header CF-Connecting-IP;

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
    nginx nginx-ssl
  ];

}