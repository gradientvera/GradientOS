{
  ssh = 22;

  # nginx
  nginx = 80;
  nginx-proxy = 81;
  nginx-ssl = 443;
  nginx-ssl-proxy = 444;
  oauth2-proxy = 4180;
  constellation-homepage = 8099;
  gradient-homepage = 8101;

  # mmproxy
  mmproxy-quic = 445;

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
  radarr-es = 7879;
  sonarr = 8989;
  sonarr-es = 8990;
  amule-webui = 4711;
  amule-remote = 4712;
  # Manual step required! The three ports below need to be set in the Amule WebUI
  amule-ed2k = 34705;
  amule-ed2k-global = 34708; # (ed2k port + 3)
  amule-ed2k-udp = 34706;
  amule-web-controller = 4004;
  lidarr = 8686;
  prowlarr = 9696;
  profilarr = 6868;
  bazarr = 6767;
  jellyseerr = 5055;
  unpackerr = 5656;
  qbittorrent-webui = 8090;
  qbittorrent-peer = 36494;
  flaresolverr = 8191;
  ersatztv = 8409;
  tdarr-webui = 8265;
  tdarr-server = 8266;
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
  shelfmark = 8077;
  pinchflat = 8945;

  # Wolf
  wolf-http = 47989;
  wolf-https = 47984;
  wolf-control = 47999;
  wolf-rtsp = 48010;
  wolf-video-ping = 48100;
  wolf-audio-ping = 48200;

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
  forgejo-cache = 3001;
  forgejo-ssh = 222;
  openwebrx = 8073;
  nut = 3493;
  open-webui = 8100;
  ollama = 11434;
  uptime-kuma = 4003;
  attic = 8060;
  wgautomesh-gossip = 1666;
  wgautomesh-external = 33723;
  crowdsec-lapi = 8076;
  crowdsec-metrics = 6060;
  microsocks = 1079;
  olivetin = 8075;
  headscale = 8074;
  
  # Frigate, cannot be changed because fuck you
  frigate = 5000;
  frigate-api = 5001;
  frigate-mqtt-ws = 5002;
  frigate-jsmpeg = 8082;
  frigate-go2rtc = 1984;
  frigate-rtmp = 1935;
  go2rtc-rtsp = 8554;
  go2rtc-srtp = 8442;
  go2rtc-webrtc = 8555;

  # Paperless-ngx
  paperless = 28981;
  tika = 9998;
  gotenberg = 9997;

  # grafana
  grafana = 8083;
  prometheus = 8084;
  victorialogs = 8086;
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
  crafty = 8444;
  crafty-dynmap = 8125;
  crafty-server-start = 25500;
  minecraft = 25565;
  crafty-server-end = 25600;
  hytale = 5520;

}