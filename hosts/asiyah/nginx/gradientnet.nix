/*
  Internal services accessible via the gradientnet VPN.
*/
{ config, ... }:
let
  dashboard = builtins.toFile "dashboard.html" (dashboardReplaceConstants dashboardBaseHtml);
  dashboardReplaceConstants = html: builtins.replaceStrings 
    [
      "@ASIYAH@"
      "@BRIAH@"
      "@BEATRICE@"
      "@PORT-PROWLARR@"
      "@PORT-SEARX@"
    ]
    [
      "asiyah.gradient"
      "briah.gradient"
      "beatrice.gradient"
      (toString ports.prowlarr)
      (toString ports.searx)
    ]
    html;
  # TODO: Rebuild this mess ugh
  dashboardBaseHtml = (builtins.readFile ./dashboard.html);
  ports = config.gradient.currentHost.ports;
  ips = config.gradient.const.wireguard.addresses;
  vhostConfig = ''
    allow ${ips.gradientnet.gradientnet}/24;
    deny all;
  '';
  mkInternalVHost = { port, address ? "127.0.0.1" }: {
    listenAddresses = [ ips.gradientnet.asiyah ];
    extraConfig = vhostConfig;
    useACMEHost = "gradient.moe";
    forceSSL = true;
    locations."/" = {
      proxyPass = "http://${address}:${toString port}";
      proxyWebsockets = true;
    };
  };
in
{

  services.nginx.virtualHosts."asiyah.gradient.moe" = {
    listenAddresses = [ ips.gradientnet.asiyah ];
    extraConfig = vhostConfig;
    useACMEHost = "gradient.moe";
    forceSSL = true;

    serverAliases = [
      "asiyah.gradient"
      ips.gradientnet.asiyah
    ];

    locations."/".extraConfig = ''
      root ${builtins.dirOf dashboard}/;
      try_files /${builtins.baseNameOf dashboard} =404;
    '';
  };

  services.nginx.virtualHosts."search.asiyah.gradient.moe" = mkInternalVHost { port = ports.searx; };
  services.nginx.virtualHosts."trilium.asiyah.gradient.moe" = mkInternalVHost { port = ports.trilium; };
  services.nginx.virtualHosts."syncthing.asiyah.gradient.moe" = mkInternalVHost { port = ports.syncthing; };
  services.nginx.virtualHosts."scrutiny.asiyah.gradient.moe" = mkInternalVHost { port = ports.scrutiny; };
  services.nginx.virtualHosts."bitwarden.asiyah.gradient.moe" = mkInternalVHost { port = ports.vaultwarden; };
  services.nginx.virtualHosts."trmnl.asiyah.gradient.moe" = mkInternalVHost { port = ports.trmnl; };
  services.nginx.virtualHosts."radio.asiyah.gradient.moe" = mkInternalVHost { port = ports.openwebrx; };
  services.nginx.virtualHosts."esphome.asiyah.gradient.moe" = mkInternalVHost { port = ports.esphome; };
  services.nginx.virtualHosts."zigbee.asiyah.gradient.moe" = mkInternalVHost { port = ports.zigbee2mqtt; };
  services.nginx.virtualHosts."hass.asiyah.gradient.moe" = mkInternalVHost { port = ports.home-assistant; };
  services.nginx.virtualHosts."jellyfin.asiyah.gradient.moe" = mkInternalVHost { port = ports.jellyfin-http; };
  services.nginx.virtualHosts."k1c.asiyah.gradient.moe" = mkInternalVHost { address = "192.168.1.27"; port = 80; };

}