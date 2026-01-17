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
}