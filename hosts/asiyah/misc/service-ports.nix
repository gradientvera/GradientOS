{
  ssh = 22;

  # nginx
  nginx = 80;
  nginx-ssl = 443;
  oauth2-proxy = 4180;
  vdo-ninja = 8082;

  # wireguard
  gradientnet = 1194;
  lilynet = 1195;
  slugcatnet = 1196;

  # media stack
  jellyfin-http = 8096;
  jellyfin-https = 8920;
  jellyfin-service-discovery = 1900;
  jellyfin-client-discovery = 7359;
  radarr = 7878;
  sonarr = 8989;
  prowlarr = 9696;
  bazarr = 6767;
  jellyseerr = 5055;
  qbittorrent-webui = 8090;
  qbittorrent-peer = 6881;
  flaresolverr = 8191;
  ersatztv = 8409;
  tdarr-webui = 8265;
  tdarr-server = 8266;

  # misc
  redis-oauth2 = 6380;
  trilium = 8081;
  searx = 8089;
  tor = 9050;

  # grafana
  grafana = 8083;
  prometheus = 8084;
  prometheus-node-exporter = 8085;
  loki = 8086;
  promtail = 8087;
  
  # game servers
  palworld = 8211;
  project-zomboid = 16261;
  project-zomboid-direct = 16262;
  project-zomboid-steam-1 = 21971;
  project-zomboid-steam-2 = 21972;

  # DNS
  dns-lan = 54;
  dns-gradientnet = 55;
  dns-lilynet = 56;
  dns-slugcatnet = 57;
}