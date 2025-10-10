/*
  Public constellation.moe website.
*/
{ self, lib, ports, ... }:
{

  security.acme.certs."constellation.moe" = {
    dnsProvider = "cloudflare";
    extraDomainNames = lib.mkForce [
      "*.constellation.moe"
      "*.asiyah.constellation.moe"
    ];
  };

  services.nginx.virtualHosts = {
  
    "constellation.moe" = {
      root = self.inputs.constellation-moe;
      enableACME = true;
      acmeRoot = null;
      quic = true;
      forceSSL = true;
      serverAliases = [
        "www.constellation.moe"
      ];
    };

    "neith.constellation.moe" = {
      useACMEHost = "constellation.moe";
      forceSSL = true;

      locations."/" = {
        return = "301 https://constellation.moe$request_uri";
      };
      
      locations."/.well-known/discord" = {
        return = "200 dh=c6efaef2bdecf33aa37bf661e003f57442183211";
      };
    };

    "remie.constellation.moe" = {
      useACMEHost = "constellation.moe";
      forceSSL = true;
      
      locations."/" = {
        return = "301 https://constellation.moe$request_uri";
      };

      locations."/.well-known/discord" = {
        return = "200 dh=1bcf1ec16a3b9abcf5df802a38bf0de78075303a";
      };
    };

    "vera.constellation.moe" = {
      useACMEHost = "constellation.moe";
      forceSSL = true;
      
      locations."/" = {
        return = "301 https://constellation.moe$request_uri";
      };

      locations."/.well-known/discord" = {
        return = "200 dh=5d358d1a3d245e6375922193e53fdd0ab83b619b";
      };
    };

    "adventure.constellation.moe" = {
      useACMEHost = "constellation.moe";
      forceSSL = true;
      root = "/data/adventure";
      extraConfig = ''
        auth_basic "Constellation Adventure: Extended Cut";
        auth_basic_user_file /data/adventure/.htpasswd;
      '';
    };

  };

}