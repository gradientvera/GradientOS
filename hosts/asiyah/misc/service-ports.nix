{
  ssh = 22;

  # nginx
  nginx = 80;
  nginx-ssl = 443;
  oauth2-proxy = 4180;
  constellation-homepage = 8099;
  gradient-homepage = 8101;

  # wireguard
  gradientnet = 1194;
  lilynet = 1195;

  # kanidm
  kanidm = 8443;
  kanidm-ldap = 3636;

  # mediarr stack
  jellyfin-http = 8096;
  jellyfin-https = 8920;
  jellyfin-service-discovery = 1901;
  jellyfin-client-discovery = 7359;
  radarr = 7878;
  sonarr = 8989;
  lidarr = 8686;
  readarr = 8787;
  prowlarr = 9696;
  bazarr = 6767;
  jellyseerr = 5055;
  unpackerr = 5656;
  qbittorrent-webui = 8090;
  qbittorrent-peer = 36494;
  flaresolverr = 8191;
  ersatztv = 8409;
  tdarr-webui = 8265;
  tdarr-server = 8266;
  bitmagnet-webui = 3333;
  bitmagnet-peer = 3334;
  mikochi = 8091;
  cross-seed = 2468;
  sabnzbd = 8092;
  mediarr-openssh = 2222;
  slskd = 5030;
  slskd-peer = 26156;
  romm = 8095;
  neko = 8097;
  neko-epr-start = 52000;
  neko-epr-end = 52100;
  proxy-vpn = 1080;
  proxy-vpn-uk = 1081;
  calibre-web-automated = 8078;
  calibre-downloader = 8077;
  pinchflat = 8945;

  # NFS
  nfsd = 2049;
  statd = 4000;
  lockd = 4001;
  mountd = 4002;

  # misc
  home-assistant = 8123;
  zigbee2mqtt = 8124;
  esphome = 6052;
  redis-forgejo = 6381;
  redis-open-webui = 6382;
  postgresql = 5432;
  trilium = 8081;
  searx = 8089;
  mqtt = 1883;
  tor = 9050;
  pufferpanel = 8098;
  pufferpanel-sftp = 5657;
  ange-spice = 5900;
  syncthing = 8384;
  vaultwarden = 8222;
  forgejo = 3000;
  forgejo-ssh = 222;
  trmnl = 2300;
  openwebrx = 8073;
  nut = 3493;
  open-webui = 8100;
  ollama = 11434;
  uptime-kuma = 4003;
  
  # Paperless-ngx
  paperless = 28981;
  tika = 9998;
  gotenberg = 9997;

  # grafana
  grafana = 8083;
  prometheus = 8084;
  prometheus-node-exporter = 8085;
  loki = 8086;
  alloy = 8087;
  victoriametrics = 8428;
  
  # scrutiny
  scrutiny = 8093;
  influxdb = 8094;

  # game servers
  palworld = 8211;
  project-zomboid = 16261;
  project-zomboid-direct = 16262;
  project-zomboid-steam-1 = 21971;
  project-zomboid-steam-2 = 21972;
}