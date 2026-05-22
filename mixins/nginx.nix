# Shared Nginx config
{ pkgs, lib, ... }:
{

  gradient.nginx.enableQuic = false;
  gradient.nginx.enableBlockAIBots = true;

  services.nginx = {
    # Master nixpkgs branch for quicker CVE fixes
    package = pkgs.master.nginx.override {
      withSlice = true;
    };

    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;
    recommendedBrotliSettings = true;
    proxyTimeout = "120s";

    enableQuicBPF = true;

    logError = "/var/log/nginx/error.log";

    prependConfig = ''
      error_log syslog:server=unix:/dev/log;
    '';

    commonHttpConfig = ''
      resolver 127.0.0.1 valid=5s;
      
      log_format combinedwithfqdn '$host:$server_port $remote_addr - $remote_user [$time_local] '
                                  '"$request" $status $body_bytes_sent '
                                  '"$http_referer" "$http_user_agent"';

      access_log /var/log/nginx/access.log combinedwithfqdn;
      access_log syslog:server=unix:/dev/log combinedwithfqdn;
    '';

  };

  # Keep restarting nginx no matter what
  systemd.services.nginx.startLimitIntervalSec = lib.mkForce 0;
  systemd.services.nginx.startLimitBurst = lib.mkForce 0;
  systemd.services.nginx.serviceConfig.Restart = lib.mkForce "always";

}