{ ... }:
{

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

}