{ config, pkgs, lib, ... }:
let
  cfg = config.services.mmproxy-rs;
in
{

  options = {
    services.mmproxy-rs.enable = lib.mkEnableOption "all defined mmproxy-rs instances";

    services.mmproxy-rs.package = lib.mkPackageOption pkgs "mmproxy-rs" { };

    services.mmproxy-rs.instances = lib.mkOption {
      default = {};
      type = lib.types.attrsOf (lib.types.submodule {
        options = {
          enable = lib.mkOption {
            type = lib.types.bool;
            default = true;
            example = false;
            description = "Whether to enable this mmproxy-rs instance. Keep in mind this is true by default.";
          };

          ipv4 = lib.mkOption {
            type = lib.types.str;
            example = "127.0.0.1:443";
            description = "Address to which IPv4 traffic will be forwarded to";
          };

          ipv6 = lib.mkOption {
            type = lib.types.str;
            example = "[::1]:443";
            description = "Address to which IPv6 traffic will be forwarded to";
          };

          allowedSubnets = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = [
              "0.0.0.0/0"
              "::/0"
            ];
            example = [
              "192.168.1.0/24"
            ];
            description = "Number of seconds after which UDP socket will be cleaned up";
          };

          closeAfter = lib.mkOption {
            type = lib.types.int;
            default = 60;
            example = 30;
            description = "Number of seconds after which UDP socket will be cleaned up";
          };

          listenAddress = lib.mkOption {
            type = lib.types.str;
            example = "0.0.0.0:8443";
            description = "Address the proxy listens on";
          };

          listeners = lib.mkOption {
            type = lib.types.int;
            default = 1;
            example = 10;
            description = "Number of listener sockets that will be opened for the listen address";
          };

          protocol = lib.mkOption {
            type = lib.types.enum [ "tcp" "udp" ];
            default = "tcp";
            example = "udp";
            description = "Protocol that will be proxied: tcp, udp.";
          };

          mark = lib.mkOption {
            type = lib.types.int;
            default = 0;
            example = 123;
            description = "The mark that will be set on outbound packets";
          };

          openFirewall = lib.mkEnableOption "firewall rules to open the listen port";
        };

      });
    };
  };


  config = lib.mkIf cfg.enable {
    networking.firewall.allowedUDPPorts = 
      (lib.mapAttrsToList (_: v: lib.toInt (lib.last (lib.splitString ":" v.listenAddress))) (lib.filterAttrs (n: v: v.openFirewall) cfg.instances));

    systemd.services = (lib.mapAttrs' (name: value: lib.nameValuePair "mmproxyrs-${name}" (
      let
        ipv4Addr = (lib.elemAt (lib.splitString ":" value.ipv4) 0);
        ipv6Addr = lib.removePrefix "[" (lib.elemAt (lib.splitString "]" value.ipv6) 0);
      in {
      enable = value.enable;
      wantedBy = [ "multi-user.target" ];
      path = [ pkgs.iproute2 pkgs.iptables ];
      serviceConfig =
      let
        allowedSubnetsFile = toString (pkgs.writeText "mmproxyrs-${name}-allowed-subnets.txt" (lib.concatStringsSep "\n" value.allowedSubnets));
      in
      {
        User = "root";
        Group = "root";
        ExecStart = lib.escapeShellArgs (
          [
            (lib.getExe cfg.package)
            "--ipv4" value.ipv4
            "--ipv6" value.ipv6
            "--allowed-subnets" allowedSubnetsFile
            "--close-after" (toString value.closeAfter)
            "--listen-addr" value.listenAddress
            "--listeners" (toString value.listeners)
            "--protocol" value.protocol
            "--mark" (toString value.mark)
          ]);
        Restart = "on-failure";
      };
      preStart = ''
        ip rule add from ${ipv4Addr}/32 iif lo table ${toString value.mark}
        ip -6 rule add from ${ipv6Addr}/128 iif lo table ${toString value.mark}
        ip route add local 0.0.0.0/0 dev lo table ${toString value.mark}
        ip -6 route add local ::0/0 dev lo table ${toString value.mark}

        iptables -t mangle -A POSTROUTING -m mark --mark ${toString value.mark} -j CONNMARK --save-mark
        iptables -t mangle -A PREROUTING -j CONNMARK --restore-mark
      '';
      postStop = ''
        ip rule del from ${ipv4Addr}/32 iif lo table ${toString value.mark}
        ip -6 rule del from ${ipv6Addr}/128 iif lo table ${toString value.mark}
        ip route del local 0.0.0.0/0 dev lo table ${toString value.mark}
        ip -6 route del local ::0/0 dev lo table ${toString value.mark}

        iptables -t mangle -D POSTROUTING -m mark --mark ${toString value.mark} -j CONNMARK --save-mark
        iptables -t mangle -D PREROUTING -j CONNMARK --restore-mark
      '';
    })) cfg.instances);
  };

}