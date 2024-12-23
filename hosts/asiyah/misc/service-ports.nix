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

  # mediarr stack
  jellyfin-http = 8096;
  jellyfin-https = 8920;
  jellyfin-service-discovery = 1900;
  jellyfin-client-discovery = 7359;
  radarr = 7878;
  sonarr = 8989;
  lidarr = 8686;
  readarr = 8787;
  prowlarr = 9696;
  bazarr = 6767;
  bazarr-embedded = 6768;
  jellyseerr = 5055;
  unpackerr = 5656;
  qbittorrent-webui = 8090;
  qbittorrent-peer = 36494;
  flaresolverr = 8191;
  ersatztv = 8409;
  tdarr-webui = 8265;
  tdarr-server = 8266;
  whisper = 9000;
  bitmagnet-webui = 3333;
  bitmagnet-peer = 3334;
  mikochi = 8091;
  cross-seed = 2468;
  sabnzbd = 8092;
  mediarr-openssh = 2222;
  slskd = 5030;
  slskd-peer = 26156;

  # NFS
  nfsd = 2049;
  statd = 4000;
  lockd = 4001;
  mountd = 4002;

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
  
  # scrutiny
  scrutiny = 8093;
  influxdb = 8094;

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