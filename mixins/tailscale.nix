{ config, pkgs, lib, ... }:
let
  hostName = config.networking.hostName;
  isBriah = hostName == "briah";
  isAsiyah = hostName == "asiyah";
  isNeith = hostName == "neith-deck";
in
{

  sops.secrets.tailscale-auth-key = {
    sopsFile = ../core/secrets/secrets.yml;
    restartUnits = if !isNeith then [ "tailscaled.service" "tailscaled-autoconnect.service" ] else [];
  };

  sops.secrets.tailscale-auth-key-neith = {
    sopsFile = ../core/secrets/secrets.yml;
    restartUnits = if isNeith then [ "tailscaled.service" "tailscaled-autoconnect.service" ] else [];
  };

  services.tailscale = {
    enable = true;
    openFirewall = true;
    authKeyFile = if !isNeith 
      then config.sops.secrets.tailscale-auth-key.path 
      else config.sops.secrets.tailscale-auth-key-neith.path;
    useRoutingFeatures = "both";
    extraUpFlags = [
      "--login-server=https://headscale.constellation.moe"
    ];
    extraSetFlags = [] ++ (if (isAsiyah || isBriah) then [
      "--advertise-exit-node"
    ] else []);
  };

  environment.systemPackages = if config.gradient.profiles.desktop.enable then [ pkgs.tail-tray ] else [];

  environment.etc."NetworkManager/dnsmasq.d/tailscale.conf".text = ''
server=/tailnet.constellation.moe/100.100.100.100
domain=tailnet.constellation.moe
'';

  networking.search = [
    "tailnet.constellation.moe"
  ];
}