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
  neithDeckHost = "neith-deck";
  beatriceHost = "beatrice";
  erikaHost = "erika";
  featherineHost = "featherine";

  hostName = config.networking.hostName;
  isAsiyah = hostName == asiyahHost;
  isBriah = hostName == briahHost;

  mkRatholeServices = servicePrefix: mode: ports:
    builtins.listToAttrs
      (builtins.concatLists
        (builtins.map (port:
          [
            {
              name = "${servicePrefix}-${toString port}-tcp";
              value = if mode == "server" then {
                bind_addr = "0.0.0.0:${toString port}";
                type = "tcp";
              } else if mode == "client" then {
                local_addr = "127.0.0.1:${toString port}";
                type = "tcp";
              } else throw "Expected mode to be either 'server' or 'client'";
            }
            {
              name = "${servicePrefix}-${toString port}-udp";
              value = if mode == "server" then {
                bind_addr = "0.0.0.0:${toString port}";
                type = "udp";
              } else if mode == "client" then {
                local_addr = "127.0.0.1:${toString port}";
                type = "udp";
              } else throw "Expected mode to be either 'server' or 'client'";
            }
          ]
        ) ports)
      );

  asiyahForwardedPorts = with asiyahPorts; [
    #nginx
    #nginx-ssl

    lilynet

    forgejo-ssh

    minecraft
  ];

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

    (lib.mkIf isBriah {
      networking.firewall = {
        allowedTCPPorts = with briahPorts; [ gradientnet ] ++ asiyahForwardedPorts;
        allowedUDPPorts = with briahPorts; [ gradientnet ] ++ asiyahForwardedPorts;
      };

      networking.firewall.interfaces.gradientnet = {
        allowedTCPPorts = with briahPorts; [ rathole ];
        allowedUDPPorts = with briahPorts; [ rathole ];
      };

      services.rathole = {
        enable = true;
        role = "server";
        credentialsFile = config.sops.secrets.rathole-credentials-server.path;
        settings = {
          server = {
            bind_addr = "${addr.gradientnet.briah}:${toString briahPorts.rathole}";
            services = (mkRatholeServices "asiyah" "server" asiyahForwardedPorts);
          };
        };
      };

      services.mmproxy-rs.enable = false;
      services.mmproxy-rs.reverseProxies.quic = {
        enable = true;
        listeners = 2;
        openFirewall = true;
        protocol = "udp";
        listenAddress = "[::]:${toString briahPorts.https}";
        forwardAddress = "${addr.gradientnet.asiyah}:${toString asiyahPorts.mmproxy-quic}";
      };
    })

    (lib.mkIf isAsiyah {
      networking.firewall = {
        allowedTCPPorts = with asiyahPorts; [ lilynet ] ++ asiyahForwardedPorts;
        allowedUDPPorts = with asiyahPorts; [ lilynet ] ++ asiyahForwardedPorts;
      };

      services.rathole = {
        enable = true;
        role = "client";
        credentialsFile = config.sops.secrets.rathole-credentials-client.path;
        settings = {
          client = {
            remote_addr = "${addr.gradientnet.briah}:${toString briahPorts.rathole}";
            services = (mkRatholeServices "asiyah" "client" asiyahForwardedPorts);
          };
        };
      };

      services.mmproxy-rs.enable = false;
      services.mmproxy-rs.mmproxies.quic = {
        openFirewall = true;
        # Use .2 instead of .1 to allow reverse proxying on nginx lmao
        ipv4 = "127.0.0.2:${toString asiyahPorts.nginx-ssl}";
        ipv6 = "[::2]:${toString asiyahPorts.nginx-ssl}";
        allowedSubnets = [ "${addr.gradientnet.gradientnet}/24" ];
        protocol = "udp";
        mark = 123;
        listenAddress = "${addr.gradientnet.asiyah}:${toString asiyahPorts.mmproxy-quic}";
      };
    })

    (lib.mkIf (builtins.any (v: hostName == v) [ asiyahHost briahHost yetzirahHost bernkastelHost beatriceHost erikaHost featherineHost ]) {
      systemd.network.wait-online.ignoredInterfaces = [ "gradientnet" ];

      # Allow SSH over gradientnet
      networking.firewall.interfaces.gradientnet.allowedTCPPorts = config.services.openssh.ports;

      networking.hosts = generateHosts ".gradient" addr.gradientnet;
 
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
            allowedIPs = [ "${beatrice}/32" ];
            publicKey = keys.beatrice;
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

    (lib.mkIf (builtins.any (v: hostName == v) [ asiyahHost yetzirahHost bernkastelHost neithDeckHost beatriceHost erikaHost featherineHost ]) {
      systemd.network.wait-online.ignoredInterfaces = [ "lilynet" ];

      networking.hosts = generateHosts ".lily" addr.lilynet;

      networking.wireguard.interfaces.lilynet = with addr.lilynet; {
        ips = ["${addr.lilynet.${hostName}}/${if isAsiyah then "24" else "32"}"];
        listenPort = lib.mkIf isAsiyah asiyahPorts.lilynet;
        postSetup = lib.mkIf isAsiyah (gen-post-setup "lilynet" "eno1");
        postShutdown = lib.mkIf isAsiyah (gen-post-shutdown "lilynet" "eno1");
        privateKeyFile = private-key;
        dynamicEndpointRefreshSeconds = if isAsiyah then 0 else 25;
        peers = (if isAsiyah then [
          {
            allowedIPs = [ "${yetzirah}/32" ];
            publicKey = keys.yetzirah;
          }
          {
            allowedIPs = [ "${bernkastel}/32" ];
            publicKey = keys.bernkastel;
          }
          {
            allowedIPs = [ "${neith-deck}/32" ];
            publicKey = keys.neith-deck;
          }
          {
            allowedIPs = [ "${beatrice}/32" ];
            publicKey = keys.beatrice;
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
            allowedIPs = [ "${neith}/32" ];
            publicKey = keys.neith;
          }
          {
            allowedIPs = [ "${remie}/32" ];
            publicKey = keys.remie;
          }
        ] else [
          {
            allowedIPs = [ "${lilynet}/24" ];
            endpoint = "vpn.gradient.moe:${toString asiyahPorts.lilynet}";
            publicKey = keys.asiyah;
            persistentKeepalive = 25;
            dynamicEndpointRefreshSeconds = 25;
            dynamicEndpointRefreshRestartSeconds = 10;
          }
        ]);
      };
    })

  ];

}