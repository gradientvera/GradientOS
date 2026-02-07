{ config, ... }:
{
  services.tailscale = {
    enable = true;
    openFirewall = true;
    authKeyFile = config.sops.secrets.tailscale-auth-key.path;
    useRoutingFeatures = "both";
    extraUpFlags = [
      "--login-server=https://headscale.constellation.moe"
    ];
    extraSetFlags = [
      "--advertise-exit-node"
    ];
  };

  environment.etc."NetworkManager/dnsmasq.d/tailscale.conf".text = ''
server=/tailnet.constellation.moe/100.100.100.100
'';
}