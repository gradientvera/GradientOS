/*
  Internal services accessible via the gradientnet VPN.
*/
{ config, ... }:
let
  localAddresses = config.gradient.const.localAddresses;
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

  services.nginx.virtualHosts = {
    "search.asiyah.gradient.moe" = mkInternalVHost { port = ports.searx; };
    "trilium.asiyah.gradient.moe" = mkInternalVHost { port = ports.trilium; };
    "syncthing.asiyah.gradient.moe" = mkInternalVHost { port = ports.syncthing; };
    "scrutiny.asiyah.gradient.moe" = mkInternalVHost { port = ports.scrutiny; };
    "bitwarden.asiyah.gradient.moe" = mkInternalVHost { port = ports.vaultwarden; };
    "trmnl.asiyah.gradient.moe" = mkInternalVHost { port = ports.trmnl; };
    "radio.asiyah.gradient.moe" = mkInternalVHost { port = ports.openwebrx; };
    "esphome.asiyah.gradient.moe" = mkInternalVHost { port = ports.esphome; };
    "zigbee.asiyah.gradient.moe" = mkInternalVHost { port = ports.zigbee2mqtt; };
    "hass.asiyah.gradient.moe" = mkInternalVHost { port = ports.home-assistant; };
    "jellyfin.asiyah.gradient.moe" = mkInternalVHost { port = ports.jellyfin-http; };
    "k1c.asiyah.gradient.moe" = mkInternalVHost { address = "192.168.1.27"; port = 80; };
    "angela.asiyah.gradient.moe" = mkInternalVHost { address = localAddresses.vacuum-angela; port = 80; };
    "mute.asiyah.gradient.moe" = mkInternalVHost { address = localAddresses.vacuum-mute; port = 80; };
  };
  
}