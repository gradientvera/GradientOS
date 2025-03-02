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
in
{

  services.nginx.virtualHosts."asiyah.gradient" = with ips.gradientnet; {
    listenAddresses = [ asiyah ];
    
    serverAliases = [
      asiyah
    ];

    locations."/".extraConfig = ''
      if ($host = ${asiyah}) {
        return 301 http://$host/dashboardIps/;
      }
      root ${builtins.dirOf dashboard}/;
      try_files /${builtins.baseNameOf dashboard} =404;
      sub_filter '@DASHBOARD_LOCATION@' '${dashboard}';
      sub_filter_once off;
    '';

    locations."/dashboardIps/".extraConfig = ''
      root ${builtins.dirOf dashboard}/;
      try_files /${builtins.baseNameOf dashboard} =404;
      sub_filter 'asiyah.gradient' '${asiyah}';
      sub_filter 'briah.gradient' '${briah}';
      sub_filter 'beatrice.gradient' '${beatrice}';
      sub_filter '@DASHBOARD_LOCATION@' '${dashboard}';
      sub_filter_once off;
    '';
    
    locations."/memory_repository/" = {
      proxyPass = "http://127.0.0.1:${toString ports.trilium}/";
      extraConfig = ''
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_http_version 1.1;
        proxy_read_timeout 90;
        allow ${gradientnet}/24;
        deny all;
      '';
    };

    locations."/grafana/" = let grafana = config.services.grafana.settings.server; in {
      proxyPass = "http://${toString grafana.http_addr}:${toString grafana.http_port}";
      proxyWebsockets = true;
      extraConfig = ''
        allow ${gradientnet}/24;
        deny all;
      '';
    };

    # locations."/syncthing/" = {
    #   extraConfig = ''
    #     proxy_set_header        Host $host;
    #     proxy_set_header        X-Real-IP $remote_addr;
    #     proxy_set_header        X-Forwarded-For $proxy_add_x_forwarded_for;
    #     proxy_set_header        X-Forwarded-Proto $scheme;

    #     proxy_pass http://127.0.0.1:${toString ports.syncthing}/;

    #     proxy_read_timeout      600s;
    #     proxy_send_timeout      600s;
    #     allow ${gradientnet}/24;
    #     deny all;
    #   '';
    # };
  };

}