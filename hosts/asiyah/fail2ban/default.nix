{ config, pkgs, ... }:
let
  addresses = config.gradient.const.wireguard.addresses;
  ports = import ../misc/service-ports.nix;
in
{

  imports = [
    ./actions/default.nix
    ./filters/default.nix
  ];

  services.fail2ban = {
    enable = true;

    extraPackages = with pkgs; [
      jq
      gawk
      curl
      apprise
      coreutils-full
    ];

    ignoreIP = [
      "10.0.0.0/8"
      "${addresses.gradientnet.gradientnet}/24"
      "${addresses.lilynet.lilynet}/24"
    ];

    bantime-increment = {
      enable = true;
      rndtime = "24h";
      maxtime = "48h";
      overalljails = true;
    };

    jails =
      let
        mkCloudflare = zone: ''cloudflare-secure[actname="cloudflare-${zone}", cftokenpath="${config.sops.secrets.fail2ban-cf-token.path}", cfzone="${zone}"]'';
        mkCloudflareAll = ''
          ${(mkCloudflare "gradient.moe")}
                     ${(mkCloudflare "zumorica.es")}
                     ${(mkCloudflare "constellation.moe")}'';
        mkNginxJail = { filter, maxretry ? 10, findtime ? 3600, backend ? "systemd" }: ''
          enabled  = true
          port     = http,https
          backend  = ${backend}
          filter   = ${filter}
          findtime = ${toString findtime}
          maxretry = ${toString maxretry}
          journalmatch = _SYSTEMD_UNIT=nginx.service + _COMM=nginx
          logpath  = %(nginx_access_log)s
          action   = ${mkCloudflareAll}
                    iptables-multiport[port="http,https"]
                    apprise
        '';
      in
    {
      nginx-bad-request = mkNginxJail { filter = "nginx-bad-request"; };
      nginx-botsearch = mkNginxJail { filter = "nginx-botsearch"; };
      nginx-forbidden = mkNginxJail { filter = "nginx-forbidden"; };
      nginx-http-auth = mkNginxJail { filter = "nginx-http-auth"; };
      nginx-error-common = mkNginxJail { filter = "nginx-error-common"; backend = "auto"; };
      # As per https://notes.abhinavsarkar.net/2022/fail2ban-nginx-cloudflare-nixos
      nginx-noagent = mkNginxJail { filter = "nginx-noagent"; maxretry = 1; backend = "auto"; };

      sshd-mediarr = ''
        enabled = true
        maxretry = 5
        findtime = 3600
        filter = sshd[mode=aggressive,_daemon=mediarr-openssh(?:-session)?]
        port = ${toString ports.mediarr-openssh}
        backend = pyinotify
        logpath = /var/lib/mediarr/sshlogs/current
        action = iptables-multiport[name=fail2ban-mediarr-openssh, port=${toString ports.mediarr-openssh}]
                 apprise
      '';

      # As per https://www.home-assistant.io/integrations/fail2ban/
      home-assistant = ''
        enabled = true
        maxretry = 5
        filter = hass
        action = iptables-allports[name=HASS]
        backend = auto
        logpath = /var/lib/hass/home-assistant.log
      '';

      jellyfin = ''
        enabled = true
        maxretry = 3
        backend = auto
        port = 80,443
        protocol = tcp
        filter = jellyfin
        bantime = 86400
        findtime = 43200
        logpath = /var/lib/mediarr/jellyfin/config/log/log*.log
      '';
    };

  };

}