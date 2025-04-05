{ config, pkgs, ... }:
let
  addresses = config.gradient.const.wireguard.addresses;
  ports = import ./misc/service-ports.nix;
in
{

  services.fail2ban = {
    enable = true;
    extraPackages = [ pkgs.curl pkgs.jq pkgs.apprise pkgs.gawk pkgs.coreutils-full ];
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
        mkNginxJail = { filter, maxretry ? 10, findtime ? 3600 }: ''
          enabled  = true
          port     = http,https
          backend  = auto
          filter   = ${filter}
          findtime = ${toString findtime}
          maxretry = ${toString maxretry}
          logpath  = %(nginx_access_log)s
          action   = ${mkCloudflareAll}
                    iptables-multiport[port="http,https"]
                    apprise
        '';
      in
    {
      nginx-bad-request = mkNginxJail { filter = "nginx-bad-request"; };
      nginx-botsearch = mkNginxJail { filter = "nginx-botsearch"; };
      nginx-error-common = mkNginxJail { filter = "nginx-error-common"; };
      nginx-forbidden = mkNginxJail { filter = "nginx-forbidden"; };
      nginx-http-auth = mkNginxJail { filter = "nginx-http-auth"; };
      # As per https://notes.abhinavsarkar.net/2022/fail2ban-nginx-cloudflare-nixos
      nginx-noagent = mkNginxJail { filter = "nginx-noagent"; maxretry = 1; };

      sshd-mediarr = ''
        enabled = true
        filter = sshd
        port = ${toString ports.mediarr-openssh}
        journalmatch = _SYSTEMD_UNIT=podman-mediarr-openssh.service
        backend = systemd
        action = iptables-multiport[port=${toString ports.mediarr-openssh}]
                 apprise
      '';
    };

  };

  environment.etc."fail2ban/action.d/cloudflare-secure.conf".text = ''
    [Definition]
    actionstart =
    actionstop =
    actioncheck =
    actionban = TOKEN=$(cat <cftokenpath>)
                ZONEID=$(curl -s <_cf_api_params> \
                          -X GET <_cf_api_url_zones> \
                        | jq -r '.result[] | select(.name=="<cfzone>") | .id')
                curl -s <_cf_api_params> \
                  -X POST "<_cf_api_url>" \
                  --data '{"mode":"<cfmode>","configuration":{"target":"<cftarget>","value":"<ip>"},"notes":"<notes>"}'
    actionunban = TOKEN=$(cat <cftokenpath>)
                  ZONEID=$(curl -s <_cf_api_params> \
                            -X GET <_cf_api_url_zones> \
                          | jq -r '.result[] | select(.name=="<cfzone>") | .id')
                  id=$(curl -s -G -X GET "<_cf_api_url>" \
                      -d "mode=<cfmode>" -d "notes=<notes>" -d "configuration.target=<cftarget>" -d "configuration.value=<ip>" \
                      <_cf_api_params> \
                    | awk -F"[,:}]" '{for(i=1;i<=NF;i++){if($i~/'id'\042/){print $(i+1)}}}' \
                    | tr -d ' "' \
                    | head -n 1)
                  if [ -z "$id" ]; then echo "<name>: id for <ip> cannot be found using target <cftarget>"; exit 0; fi; \
                  curl -s -X DELETE "<_cf_api_url>/$id" \
                      <_cf_api_params> \
                      --data '{"cascade": "none"}'

    _cf_api_params = -H "Content-type: application/json" -H "Authorization: Bearer $TOKEN"
    _cf_api_url = https://api.cloudflare.com/client/v4/zones/''${ZONEID}/firewall/access_rules/rules
    _cf_api_url_zones = https://api.cloudflare.com/client/v4/zones

    [Init]
    notes = fail2ban
    cfmode = block
    cftarget = ip
    cftokenpath =
    cfzone = 

    [Init?family=inet6]
    cftarget = ip6
  '';

  # As per https://notes.abhinavsarkar.net/2022/fail2ban-nginx-cloudflare-nixos
  environment.etc."fail2ban/filter.d/nginx-noagent.conf".text = ''
    [Definition]

    failregex = ^<HOST> -.*"-" "-"$

    ignoreregex =
  '';

}