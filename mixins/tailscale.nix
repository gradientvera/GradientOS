{ config, pkgs, lib, ... }:
{

  sops.secrets.tailscale-auth-key = {
    sopsFile = ../core/secrets/secrets.yml;
    restartUnits = [ "tailscaled.service" "tailscaled-autoconnect.service" ];
  };

  services.tailscale = {
    enable = true;
    openFirewall = true;
    authKeyFile = config.sops.secrets.tailscale-auth-key.path;
    useRoutingFeatures = "both";
    extraUpFlags = [
      "--login-server=https://headscale.constellation.moe"
      "--advertise-exit-node"
    ];
    extraSetFlags = [
      "--advertise-exit-node"
    ];
  };

  environment.systemPackages = if config.gradient.profiles.desktop.enable then [ pkgs.tail-tray ] else [];

  environment.etc."NetworkManager/dnsmasq.d/tailscale.conf".text = ''
server=/tailnet.constellation.moe/100.100.100.100
'';
}