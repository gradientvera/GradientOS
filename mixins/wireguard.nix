{ config, pkgs, lib, ... }:
let

  ipAddr = config.gradient.const.addresses;

  addr = config.gradient.const.wireguard.addresses;
  keys = config.gradient.const.wireguard.pubKeys;

  private-key = config.sops.secrets.wireguard-private-key.path;

  asiyahPorts = config.gradient.hosts.asiyah.ports;
  briahPorts = config.gradient.hosts.briah.ports;

  iptablesCmd = "${pkgs.iptables}/bin/iptables";
  ip6tablesCmd = "${pkgs.iptables}/bin/ip6tables";

  gen-post-setup = vpn: interface: 
  "
    ${iptablesCmd} -A FORWARD -i ${vpn} -j ACCEPT;
    # ${iptablesCmd} -t nat -A POSTROUTING -o ${interface} -j MASQUERADE;
    ${ip6tablesCmd} -A FORWARD -i ${vpn} -j ACCEPT;
    # ${ip6tablesCmd} -t nat -A POSTROUTING -o ${interface} -j MASQUERADE;
  ";

  gen-post-shutdown = vpn: interface:
  "
    ${iptablesCmd} -D FORWARD -i ${vpn} -j ACCEPT;
    # ${iptablesCmd} -t nat -D POSTROUTING -o ${interface} -j MASQUERADE;
    ${ip6tablesCmd} -D FORWARD -i ${vpn} -j ACCEPT;
    # ${ip6tablesCmd} -t nat -D POSTROUTING -o ${interface} -j MASQUERADE;
  ";

  generateHosts = suffix: addresses: lib.attrsets.mapAttrs' (name: value: { name = value; value = ["${name}${suffix}"]; }) addresses;

  asiyahHost = "asiyah";
  briahHost = "briah";
  yetzirahHost = "yetzirah";
  bernkastelHost = "bernkastel";
  erikaHost = "erika";
  featherineHost = "featherine";

  hostName = config.networking.hostName;
  isAsiyah = hostName == asiyahHost;
  isBriah = hostName == briahHost;

in
{

  config = lib.mkMerge [

    {
      networking.wireguard.enable = true;
      environment.systemPackages = [ pkgs.wireguard-tools ];
      boot.kernelModules = [ "wireguard" ];
      # Very spammy: boot.kernelParams = [ "wireguard.dyndbg=\"+p\"" ];
    }

    (lib.mkIf (isAsiyah || isBriah) {
      # Enables routing.
      boot.kernel.sysctl = {
        "net.ipv4.conf.all.forwarding" = lib.mkOverride 98 true;
        "net.ipv4.conf.default.forwarding" = lib.mkOverride 98 true;
        "net.ipv6.conf.all.forwarding" = lib.mkOverride 98 true;
        "net.ipv6.conf.default.forwarding" = lib.mkOverride 98 true;
      };
    })

    (lib.mkIf (builtins.any (v: hostName == v) [ asiyahHost briahHost yetzirahHost bernkastelHost erikaHost featherineHost ]) {
      systemd.network.wait-online.ignoredInterfaces = [ "gradientnet" ];

      # Allow SSH over gradientnet
      networking.firewall.interfaces.gradientnet.allowedTCPPorts = config.services.openssh.ports;

      networking.wireguard.interfaces.gradientnet = with addr.gradientnet; {
        ips = ["${addr.gradientnet.${hostName}}/${if isBriah then "24" else "32"}"];
        listenPort = if isBriah then briahPorts.gradientnet else config.gradient.currentHost.ports.wgautomesh-external;
        #postSetup = lib.mkIf isBriah (gen-post-setup "gradientnet" "eth0");
        #postShutdown = lib.mkIf isBriah (gen-post-shutdown "gradientnet" "eth0");
        privateKeyFile = private-key;
        dynamicEndpointRefreshSeconds = if isBriah then 0 else 25;
        peers = (if isBriah then [
          {
            allowedIPs = [ "${asiyah}/32" ];
            publicKey = keys.asiyah;
          }
          {
            allowedIPs = [ "${yetzirah}/32" ];
            publicKey = keys.yetzirah;
          }
          {
            allowedIPs = [ "${bernkastel}/32" ];
            publicKey = keys.bernkastel;
          }
          {
            allowedIPs = [ "${vera-phone-old}/32" ];
            publicKey = keys.vera-phone-old;
          }
          {
            allowedIPs = [ "${vera-laptop}/32" ];
            publicKey = keys.vera-laptop;
          }
          {
            allowedIPs = [ "${erika}/32" ];
            publicKey = keys.erika;
          }
          {
            allowedIPs = [ "${featherine}/32" ];
            publicKey = keys.featherine;
          }
          {
            allowedIPs = [ "${vera-phone}/32" ];
            publicKey = keys.vera-phone;
          }
          {
            allowedIPs = [ "${forgejo-deployment}/32" ];
            publicKey = keys.forgejo-deployment;
          }
        ] else [
          {
            allowedIPs = [ "${gradientnet}/24" ];
            endpoint = "vpn.gradient.moe:${toString briahPorts.gradientnet}";
            publicKey = keys.briah;
            persistentKeepalive = 25;
            dynamicEndpointRefreshSeconds = 25;
            dynamicEndpointRefreshRestartSeconds = 10;
          }
        ]);
      };

      networking.firewall.allowedTCPPorts = with config.gradient.currentHost.ports; [ wgautomesh-gossip wgautomesh-external ];
      networking.firewall.allowedUDPPorts = with config.gradient.currentHost.ports; [ wgautomesh-gossip wgautomesh-external ];

      services.wgautomesh = {
        enable = true;
        gossipSecretFile = config.sops.secrets.wgautomesh-gossip-secret.path;
        openFirewall = true;
        
        settings = {
          interface = "gradientnet";
          lan_discovery = true;
          gossip_port = config.gradient.currentHost.ports.wgautomesh-gossip;
          upnp_forward_external_port = config.gradient.currentHost.ports.wgautomesh-external;
          peers = 
            (builtins.map 
              (a: {
                    address = a.value;
                    pubkey = keys.${a.name};
                    endpoint = 
                      if a.name == "briah" then
                        "vpn.gradient.moe:${toString briahPorts.gradientnet}"
                      else
                        # Try local hostname resolution, since this is the case for most peers here
                        "${a.name}.local:${toString config.gradient.hosts.${a.name}.ports.wgautomesh-external}"; 
                  })
            (builtins.filter (a: a.name != config.networking.hostName && lib.hasAttrByPath [a.name "ports" "wgautomesh-external"] config.gradient.hosts) (lib.attrsToList addr.gradientnet)));
        };
      };

      systemd.services.wgautomesh.after = [ "wireguard-gradientnet.service" ];
      systemd.services.wgautomesh.wants = [ "wireguard-gradientnet.service" ];
    })
  ];

}