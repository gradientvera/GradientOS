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
      "@PORT-Z2M@"
      "@PORT-ESPHOME@"
      "@PORT-PROWLARR@"
      "@PORT-SEARX@"
    ]
    [
      "asiyah.gradient"
      "briah.gradient"
      "beatrice.gradient"
      (toString briahPorts.zigbee2mqtt)
      (toString briahPorts.esphome)
      (toString asiyahPorts.prowlarr)
      (toString asiyahPorts.searx)
    ]
    html;
  dashboardBaseHtml = (builtins.readFile ./dashboard.html);
  asiyahPorts = import ../../asiyah/misc/service-ports.nix;
  briahPorts = import ../../briah/misc/service-ports.nix;
  ports = import ../misc/service-ports.nix;
  ips = import ../../../misc/wireguard-addresses.nix;
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
  services.nginx.virtualHosts."grafana.asiyah.gradient.moe" = mkInternalVHost { port = config.services.grafana.settings.server.http_port; };
  services.nginx.virtualHosts."syncthing.asiyah.gradient.moe" = mkInternalVHost { port = ports.syncthing; };
  services.nginx.virtualHosts."scrutiny.asiyah.gradient.moe" = mkInternalVHost { port = ports.scrutiny; };
  services.nginx.virtualHosts."llm.asiyah.gradient.moe" = mkInternalVHost { port = ports.open-webui; };
  services.nginx.virtualHosts."bitwarden.asiyah.gradient.moe" = mkInternalVHost { port = ports.vaultwarden; };

}