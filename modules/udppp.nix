{ config, pkgs, lib, ... }:
let
  cfg = config.services.udppp;
  instanceSubmodule = {

    options = {
      enable = lib.mkOption
      {
        type = lib.types.bool;
        default = true;
        example = false;
        description = "Whether to enable this udppp instance. Keep in mind this is true by default.";
      };

      localPort = lib.mkOption {
        type = lib.types.port;
        example = 443;
        description = "The local port to which udppp should bind to";
      };

      remotePort = lib.mkOption {
        type = lib.types.port;
        example = 444;
        description = "The remote port to which UDP packets should be forwarded";
      };

      hostAddress = lib.mkOption {
        type = lib.types.str;
        description = "The remote address to which packets will be forwarded";
      };

      bindAddress = lib.mkOption {
        type = lib.types.str;
        default = "[::]";
        description = "The address on which to listen for incoming requests";
      };

      proxyProtocol = lib.mkEnableOption "proxy protocol support for this instance";
      openFirewall = lib.mkEnableOption "firewall rules to open the local port";
    };

  };
in
{

  options = {
    services.udppp.enable = lib.mkEnableOption "all defined udppp instances";

    services.udppp.package = lib.mkPackageOption pkgs "udppp" { };

    services.udppp.reverseProxies = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule instanceSubmodule);
      default = {};
    };

    services.udppp.mmproxies = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule instanceSubmodule);
      default = {};
    };
  };


  config = lib.mkIf cfg.enable {
    networking.firewall.allowedUDPPorts = 
      (lib.mapAttrsToList (_: v: v.localPort) (lib.filterAttrs (n: v: v.openFirewall) cfg.reverseProxies))
      ++
      (lib.mapAttrsToList (_: v: v.localPort) (lib.filterAttrs (n: v: v.openFirewall) cfg.mmproxies));

    systemd.services = (lib.mapAttrs' (name: value: lib.nameValuePair "udppp-reverse-proxy-${name}" {
      enable = value.enable;
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        User = "root";
        Group = "root";
        ExecStart = lib.escapeShellArgs (
          [
            "${cfg.package}/bin/udppp"
            "--mode" "1" # 1 = Reverse proxy mode
            "--local-port" (toString value.localPort)
            "--remote-port" (toString value.remotePort)
            "--host" value.hostAddress
            "--bind" value.bindAddress
            (lib.optional value.proxyProtocol "--proxyprotocol")
          ]);
        Restart = "on-failure";
      };
    }) cfg.reverseProxies)
    // (lib.mapAttrs' (name: value: lib.nameValuePair "udppp-mmproxy-${name}" {
      enable = value.enable;
      after = lib.mkIf value.proxyProtocol [ "udppp-routing.service" ];
      wants = lib.mkIf value.proxyProtocol [ "udppp-routing.service" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        User = "root";
        Group = "root";
        ExecStart = lib.escapeShellArgs (
          [
            "${cfg.package}/bin/udppp"
            "--mode" "2" # 2 = mmproxy mode
            "--local-port" (toString value.localPort)
            "--remote-port" (toString value.remotePort)
            "--host" value.hostAddress
            "--bind" value.bindAddress
            (lib.optional value.proxyProtocol "--proxyprotocol")
          ]);
        Restart = "on-failure";
      };
    }) cfg.mmproxies)
    // (lib.optionalAttrs (lib.any (x: x.value.enable && x.value.proxyProtocol) (lib.attrsToList cfg.mmproxies)) ({
      udppp-routing = {
        path = [ pkgs.iproute2 ];
        wantedBy = [ "multi-user.target" ];
        serviceConfig = {
          User = "root";
          Group = "root";
          Type = "oneshot";
          RemainAfterExit = "yes";
        };
        script = ''
          ip rule add from 127.0.0.1/8 iif lo table 123
          ip route add local 0.0.0.0/0 dev lo table 123
          ip -6 rule add from ::1/128 iif lo table 123
          ip -6 route add local ::/0 dev lo table 123
          ip rule add fwmark 1 lookup 123
        '';
        preStop = ''
          ip rule del from 127.0.0.1/8 iif lo table 123
          ip route del local 0.0.0.0/0 dev lo table 123
          ip -6 rule del from ::1/128 iif lo table 123
          ip -6 route del local ::/0 dev lo table 123
          ip rule del fwmark 1 lookup 123
        '';
      };
    }));
  };

}