/*

  Public gradient.moe website.

*/
{ self, pkgs, lib, config, ... }:
let
  ports = import ../../asiyah/misc/service-ports.nix;
in
{

  security.acme.certs."gradient.moe" = {
    dnsProvider = "cloudflare";
    extraDomainNames = lib.mkForce [
      "*.gradient.moe"
      "*.asiyah.gradient.moe"
      "*.briah.gradient.moe"
      "*.beatrice.gradient.moe"
      "*.bernkastel.gradient.moe"
      # TODO: Add the rest meh
      
      "zumorica.es"
      "*.zumorica.es"
    ];
  };

  services.nginx.virtualHosts."gradient.moe" = {
    root = toString self.inputs.gradient-moe.packages.${pkgs.system}.default;
    default = true;
    enableACME = true;
    acmeRoot = null;
    addSSL = true;
    serverAliases = [
      "www.gradient.moe"
      "zumorica.es"
      "www.zumorica.es"
    ];
    locations."/daily_gradient/data/" = {
      alias = "/data/gradient-data/";
    };
  };

  services.nginx.virtualHosts."hass.gradient.moe" = {
    useACMEHost = "gradient.moe";
    addSSL = true;
    extraConfig = ''
      proxy_buffering off;
    '';
    locations."/".extraConfig = ''
      proxy_pass http://127.0.0.1:${toString ports.home-assistant};
      proxy_set_header Host $host;
      proxy_redirect http:// https://;
      proxy_http_version 1.1;
      proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
      proxy_set_header Upgrade $http_upgrade;
      proxy_set_header Connection $connection_upgrade;
    '';
  };

}