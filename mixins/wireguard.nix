{ config, pkgs, lib, ... }:
let

  addr = config.gradient.const.wireguard.addresses;
  keys = config.gradient.const.wireguard.pubKeys;

  private-key = config.sops.secrets.wireguard-private-key.path;

  asiyahPorts = import ./../hosts/asiyah/misc/service-ports.nix;

  iptablesCmd = "${pkgs.iptables}/bin/iptables";
  ip6tablesCmd = "${pkgs.iptables}/bin/ip6tables";

  gen-post-setup = vpn: interface: 
  "
    ${iptablesCmd} -A FORWARD -i ${vpn} -j ACCEPT;
    ${iptablesCmd} -t nat -A POSTROUTING -o ${interface} -j MASQUERADE;
    ${ip6tablesCmd} -A FORWARD -i ${vpn} -j ACCEPT;
    ${ip6tablesCmd} -t nat -A POSTROUTING -o ${interface} -j MASQUERADE
  ";

  gen-post-shutdown = vpn: interface:
  "
    ${iptablesCmd} -D FORWARD -i ${vpn} -j ACCEPT;
    ${iptablesCmd} -t nat -D POSTROUTING -o ${interface} -j MASQUERADE;
    ${ip6tablesCmd} -D FORWARD -i ${vpn} -j ACCEPT;
    ${ip6tablesCmd} -t nat -D POSTROUTING -o ${interface} -j MASQUERADE
  ";

  generateHosts = suffix: addresses: lib.attrsets.mapAttrs' (name: value: { name = value; value = ["${name}${suffix}"]; }) addresses;

  asiyahHost = "asiyah";
  briahHost = "briah";
  bernkastelHost = "bernkastel";
  neithDeckHost = "neith-deck";
  beatriceHost = "beatrice";
  erikaHost = "erika";
  featherineHost = "featherine";

  hostName = config.networking.hostName;
  isAsiyah = hostName == asiyahHost;

in
{

  config = lib.mkMerge [

    {
      networking.wireguard.enable = true;
      environment.systemPackages = [ pkgs.wireguard-tools ];

      systemd.services.vpn-watchdog = {
        description = "VPN Watchdog";
        after = [ "network-pre.target" ];
        wants = [ "network.target" ];
        before = [ "network.target" ];
        wantedBy = [ "multi-user.target" ];
        enable = !isAsiyah; # Asiyah shouldn't need this.
        path = with pkgs; [ systemd unixtools.ping ];
        script = ''
          ${if config.networking.wireguard.interfaces ? "gradientnet" then ''
          VPN="${addr.gradientnet.asiyah}"
          '' else if config.networking.wireguard.interfaces ? "lilynet" then ''
          VPN="${addr.lilynet.asiyah}"
          '' else "echo 'No Wireguard VPN configured!'; exit 1"}
          FAILURES=0
          EXT_FAIL=false
          VPN_FAIL=false
          while true; do
            if(ping vpn.gradient.moe -c 1 -W 5); then
              EXT_FAIL=false
            else
              EXT_FAIL=true
            fi
            if(ping $VPN -c 1 -W 5); then
              VPN_FAIL=false
            else
              VPN_FAIL=true
            fi

            SLEEP_TIME=25
            if [ EXT_FAIL = true ] || [ VPN_FAIL = true ]; then
              FAILURES=$((FAILURES+1))
              SLEEP_TIME=$((FAILURES>25 ? 60 : FAILURES))
              echo "Failed to ping! Retrying in $SLEEP_TIME seconds..."
            fi

            if [ EXT_FAIL = false ]; then
              if((FAILURES > 2)); then
                echo "Restarting VPN services..."
                systemctl restart *wireguard* || echo "Failed to restart wireguard!"
                echo "Restarted VPN!"
                FAILURES=0
                SLEEP_TIME=25
              fi
            fi

            sleep "$SLEEP_TIME"
          done
        '';
        serviceConfig = {
          Type = "exec";
          Restart = "always";
          RestartSec = 10;
        };
      };
    }

    (lib.mkIf isAsiyah {
      # Enables routing.
      boot.kernel.sysctl = {
        "net.ipv4.conf.all.forwarding" = lib.mkOverride 98 true;
        "net.ipv4.conf.default.forwarding" = lib.mkOverride 98 true;
        "net.ipv6.conf.all.forwarding" = lib.mkOverride 98 true;
        "net.ipv6.conf.default.forwarding" = lib.mkOverride 98 true;
      };

      networking.firewall = {
        allowedTCPPorts = with asiyahPorts; [ gradientnet lilynet ];
        allowedUDPPorts = with asiyahPorts; [ gradientnet lilynet ];
      };
    })

    (lib.mkIf (builtins.any (v: hostName == v) [ asiyahHost briahHost bernkastelHost beatriceHost erikaHost featherineHost ]) {
      systemd.network.wait-online.ignoredInterfaces = [ "gradientnet" ];

      # Allow SSH over gradientnet
      networking.firewall.interfaces.gradientnet.allowedTCPPorts = config.services.openssh.ports;

      networking.hosts = generateHosts ".gradient" addr.gradientnet;

      networking.wireguard.interfaces.gradientnet = with addr.gradientnet; {
        ips = ["${addr.gradientnet.${hostName}}/${if isAsiyah then "24" else "32"}"];
        listenPort = lib.mkIf isAsiyah asiyahPorts.gradientnet;
        postSetup = lib.mkIf isAsiyah (gen-post-setup "gradientnet" "eno1");
        postShutdown = lib.mkIf isAsiyah (gen-post-shutdown "gradientnet" "eno1");
        privateKeyFile = private-key;
        peers = (if isAsiyah then [
          {
            allowedIPs = [ "${briah}/32" ];
            publicKey = keys.briah;
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
            allowedIPs = [ "${vera-phone}/32" ];
            publicKey = keys.vera-phone;
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
        ] else [
          {
            allowedIPs = [ "${gradientnet}/24" ];
            endpoint = "vpn.gradient.moe:${toString asiyahPorts.gradientnet}";
            publicKey = keys.asiyah;
            persistentKeepalive = 25;
            dynamicEndpointRefreshSeconds = 25;
            dynamicEndpointRefreshRestartSeconds = 10;
          }
          {
            allowedIPs = [ "${gradientnet}/24" ];
            endpoint = "192.168.1.48:${toString asiyahPorts.gradientnet}";
            publicKey = keys.asiyah;
          }
        ]);
      };
    })

    (lib.mkIf (builtins.any (v: hostName == v) [ asiyahHost briahHost bernkastelHost neithDeckHost beatriceHost erikaHost featherineHost ]) {
      systemd.network.wait-online.ignoredInterfaces = [ "lilynet" ];

      networking.hosts = generateHosts ".lily" addr.lilynet;

      networking.wireguard.interfaces.lilynet = with addr.lilynet; {
        ips = ["${addr.lilynet.${hostName}}/${if isAsiyah then "24" else "32"}"];
        listenPort = lib.mkIf isAsiyah asiyahPorts.lilynet;
        postSetup = lib.mkIf isAsiyah (gen-post-setup "lilynet" "eno1");
        postShutdown = lib.mkIf isAsiyah (gen-post-shutdown "lilynet" "eno1");
        privateKeyFile = private-key;
        peers = (if isAsiyah then [
          {
            allowedIPs = [ "${briah}/32" ];
            publicKey = keys.briah;
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
          {
            allowedIPs = [ "${lilynet}/24" ];
            endpoint = "192.168.1.48:${toString asiyahPorts.lilynet}";
            publicKey = keys.asiyah;
          }
        ]);
      };
    })

  ];

}