{ config, pkgs, ... }:
let
  addresses = config.gradient.const.wireguard.addresses;
  ports = config.gradient.currentHost.ports;
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
      "vpn.gradient.moe" # points to my external IP
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
        mkNginxJail = { filter, maxretry ? 10, findtime ? 3600, backend ? "auto", logpath ? "/var/log/nginx/*.log" }: ''
          enabled  = true
          port     = http,https
          backend  = ${backend}
          filter   = ${filter}
          findtime = ${toString findtime}
          maxretry = ${toString maxretry}
          journalmatch = _SYSTEMD_UNIT=nginx.service + _COMM=nginx
          logpath  = ${logpath}
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
      # As per https://notes.abhinavsarkar.net/2022/fail2ban-nginx-cloudflare-nixos
      nginx-noagent = mkNginxJail { filter = "nginx-noagent"; maxretry = 1; };

      sshd-mediarr = ''
        enabled = true
        maxretry = 1
        findtime = 3600
        filter = sshd[mode=aggressive,_daemon=mediarr-openssh(?:-session)?]
        port = ${toString ports.mediarr-openssh}
        backend = auto
        logpath = /var/lib/mediarr/sshlogs/current
        action = iptables-multiport[chain=FORWARD, name=mediarr-openssh, port=${toString ports.mediarr-openssh}]
                 apprise
      '';

      # As per https://www.home-assistant.io/integrations/fail2ban/
      home-assistant = ''
        enabled = true
        maxretry = 5
        filter = hass
        backend = auto
        logpath = /var/lib/hass/home-assistant.log
        port=80,443
        action = iptables-multiport[name=HASS]
                 apprise
      '';

      # As per https://jellyfin.org/docs/general/post-install/networking/advanced/fail2ban
      jellyfin = ''
        enabled = true
        backend = auto
        port = 80,443
        protocol = tcp
        filter = jellyfin
        maxretry = 3
        bantime = 86400
        findtime = 43200
        logpath = /var/lib/mediarr/jellyfin/config/log/*.log
        action = iptables-multiport[name=jellyfin]
                 apprise
      '';
    };

  };

}