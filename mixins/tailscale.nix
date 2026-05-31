{ config, pkgs, lib, ... }:
let
  hostName = config.networking.hostName;
  isBriah = hostName == "briah";
  isAsiyah = hostName == "asiyah";
  isNeith = hostName == "neith-deck";
  isExitNode = isAsiyah || isBriah;
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
    extraDaemonFlags = [ "--no-logs-no-support" ];
    extraUpFlags = [
      "--login-server=https://headscale.constellation.moe"
    ];
    extraSetFlags = [] ++ (if isExitNode then [
      "--advertise-exit-node=true"
    ] else [
      "--advertise-exit-node=false"
    ]);
  };

  # https://tailscale.com/docs/features/subnet-routers#enable-ip-forwarding
  boot.kernel.sysctl = if isExitNode then {
    "net.ipv4.ip_forward" = lib.mkDefault "1";
    "net.ipv6.conf.all.forwarding" = lib.mkDefault "1";
  } else {};

  # https://tailscale.com/docs/reference/best-practices/performance#ethtool-configuration
  systemd.services.tailscaled = {
    path = if isExitNode then [ pkgs.ethtool pkgs.iproute2 pkgs.coreutils ] else [];
    preStart = if isExitNode then ''
      NETDEV=$(ip -o route get 8.8.8.8 | cut -f 5 -d " ")
      ethtool -K $NETDEV rx-udp-gro-forwarding on rx-gro-list off
    '' else "";
  };

  systemd.services.tailscaled-autoconnect.startLimitIntervalSec = lib.mkForce 5;
  systemd.services.tailscaled-autoconnect.startLimitBurst = lib.mkForce 10;
  systemd.services.tailscaled-autoconnect.serviceConfig.Restart = lib.mkForce "on-failure";

  environment.systemPackages = if config.gradient.profiles.desktop.enable then [ pkgs.tail-tray ] else [];

  environment.etc."NetworkManager/dnsmasq.d/tailscale.conf".text = ''
server=/tailnet.constellation.moe/100.100.100.100
domain=tailnet.constellation.moe
'';

  networking.search = [
    "tailnet.constellation.moe"
  ];
}