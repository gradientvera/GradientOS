 { config, lib, ... }:
 let
    ports = config.gradient.currentHost.ports;
    gradientnet = config.gradient.const.wireguard.addresses.gradientnet;
    asiyahPorts = config.gradient.hosts.asiyah.ports;
in
 {

  networking.firewall.allowedTCPPorts = [ ports.http ports.https asiyahPorts.lilynet ];
  networking.firewall.allowedUDPPorts = [ ports.http ports.https asiyahPorts.lilynet ];

  services.nginx = {
    enable = true;

    defaultListen = [
      # HTTP
      { addr = "0.0.0.0"; port = ports.http; ssl = false; }
      { addr = "[::]"; port = ports.http; ssl = false; }

      # HTTPS
      { addr = "0.0.0.0"; port = ports.https; ssl = true; }
      { addr = "[::]"; port = ports.https; ssl = true; }
    ];

    virtualHosts."gradient.moe" = {
      # Only specify ONCE!
      reuseport = true;
      forceSSL = true;
      sslCertificate = "/var/lib/acme/gradient.moe/fullchain.pem";
      sslCertificateKey = "/var/lib/acme/gradient.moe/key.pem";
      sslTrustedCertificate = "/var/lib/acme/gradient.moe/chain.pem";
      serverAliases = [ "*.gradient.moe" ];
      locations."/" = {
        proxyPass = "https://${gradientnet.asiyah}:${toString asiyahPorts.nginx-ssl}";
        proxyWebsockets = true;
        extraConfig = ''
          proxy_buffering off;
          proxy_cache off;
        '';
      };
    };

    virtualHosts."constellation.moe" = {
      forceSSL = true;
      sslCertificate = "/var/lib/acme/constellation.moe/fullchain.pem";
      sslCertificateKey = "/var/lib/acme/constellation.moe/key.pem";
      sslTrustedCertificate = "/var/lib/acme/constellation.moe/chain.pem";
      serverAliases = [ "*.constellation.moe" ];
      locations."/" = {
        proxyPass = "https://${gradientnet.asiyah}:${toString asiyahPorts.nginx-ssl}";
        proxyWebsockets = true;
        extraConfig = ''
          proxy_buffering off;
          proxy_cache off;
        '';
      };
    };

    # Redirect to main site for all incorrect subdomains
    virtualHosts."_" = {
      default = true;
      forceSSL = true;
      sslCertificate = "/var/lib/acme/gradient.moe/fullchain.pem";
      sslCertificateKey = "/var/lib/acme/gradient.moe/key.pem";
      sslTrustedCertificate = "/var/lib/acme/gradient.moe/chain.pem";
      serverName = ''""'';
      locations."/" = {
        proxyPass = "https://${gradientnet.asiyah}:${toString asiyahPorts.nginx-ssl}";
        proxyWebsockets = true;
        extraConfig = ''
          proxy_buffering off;
          proxy_cache off;
        '';
      };
    };

  };

 }