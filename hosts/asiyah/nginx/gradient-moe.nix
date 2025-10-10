/*

  Public gradient.moe website.

*/
{ self, pkgs, lib, config, ... }:
let
  ports = config.gradient.currentHost.ports;
  mkReverseProxy = { port, address ? "127.0.0.1", protocol ? "http", generateOwnCert ? false, rootExtraConfig ? "", vhostExtraConfig ? "", useACMEHost ? "gradient.moe", extraConfig ? {} }: {
    useACMEHost = if (!generateOwnCert) then useACMEHost else null;
    enableACME = generateOwnCert;
    quic = true;
    forceSSL = true;
    extraConfig = vhostExtraConfig;
    locations."/" = {
      proxyPass = "${protocol}://${address}:${toString port}";
      proxyWebsockets = true;
      extraConfig = rootExtraConfig;
    };
  } // extraConfig;
in
{

  security.acme.certs."gradient.moe" = {
    dnsProvider = "cloudflare";
    extraDomainNames = lib.mkForce [
      "*.gradient.moe"
      "*.asiyah.gradient.moe"
      "*.yetzirah.gradient.moe"
      "*.beatrice.gradient.moe"
      "*.bernkastel.gradient.moe"
      # TODO: Add the rest meh
      
      "zumorica.es"
      "*.zumorica.es"
    ];
  };

  services.nginx.virtualHosts."gradient.moe" = {
    root = toString self.inputs.gradient-moe.packages.${pkgs.system}.default;
    enableACME = true;
    acmeRoot = null;
    quic = true;
    forceSSL = true;
    serverAliases = [
      "www.gradient.moe"
    ];
    locations."/daily_gradient/data/" = {
      alias = "/data/gradient-data/";
    };
  };

  # Set up reverse proxies
  services.nginx.virtualHosts = {
    "hass.gradient.moe" = mkReverseProxy { port = ports.home-assistant; vhostExtraConfig = "proxy_buffering off;"; };
    # Generate let's encrypt certificate for this domain alone for kanidm purposes.
    "identity.gradient.moe" = mkReverseProxy { port = ports.kanidm; protocol = "https"; generateOwnCert = true; };
    "git.gradient.moe" = mkReverseProxy { port = ports.forgejo; vhostExtraConfig = "client_max_body_size 4G;"; };
    "grafana.gradient.moe" = mkReverseProxy { port = config.services.grafana.settings.server.http_port; };
    # Recommended settings by https://github.com/paperless-ngx/paperless-ngx/wiki/Using-a-Reverse-Proxy-with-Paperless-ngx#nginx
    "paperless.gradient.moe" = mkReverseProxy { port = ports.paperless; vhostExtraConfig = ''client_max_body_size 4G;''; rootExtraConfig = ''proxy_redirect off; add_header Referrer-Policy "strict-origin-when-cross-origin";''; };
    "cache.gradient.moe" = mkReverseProxy { port = ports.attic; vhostExtraConfig = "client_max_body_size 32G; proxy_buffering off; proxy_cache off;"; extraConfig = { http2 = false; http3 = false; }; };
   };

  # Redirect to main site for all incorrect subdomains
  services.nginx.virtualHosts."_" = {
    default = true;
    addSSL = true;
    enableACME = false;
    useACMEHost = "gradient.moe";
    serverName = ''""'';
    globalRedirect = "gradient.moe";
  };

}