{ config, lib, ... }:
let
  ports = config.gradient.currentHost.ports;
in
{

  services.mosquitto = {
    enable = true;
    listeners = [
      # Listener for internal gradientnet purposes only. Do NOT expose to the internet.
      {
        acl = [ "pattern readwrite #" ];
        port = ports.mqtt;
        omitPasswordAuth = true;
        settings.allow_anonymous = true;
      }
    ];
  };  

  networking.firewall.allowedTCPPorts = [ ports.mqtt ];
  networking.firewall.allowedUDPPorts = [ ports.mqtt ];

  # Only allow access through LAN/VPNs or through localhost.
  networking.firewall.extraCommands = ''
    iptables -A nixos-fw -p tcp --source 192.168.0.0/24 --dport ${toString ports.mqtt} -j nixos-fw-accept
    iptables -A nixos-fw -p udp --source 192.168.0.0/24 --dport ${toString ports.mqtt} -j nixos-fw-accept
    iptables -A nixos-fw -p tcp --source 127.0.0.0/8 --dport ${toString ports.mqtt} -j nixos-fw-accept
    iptables -A nixos-fw -p udp --source 127.0.0.0/8 --dport ${toString ports.mqtt} -j nixos-fw-accept
  '';

  # Clean up after ourselves
  networking.firewall.extraStopCommands = ''
    iptables -D nixos-fw -p tcp --source 192.168.0.0/24 --dport ${toString ports.mqtt} -j nixos-fw-accept || true
    iptables -D nixos-fw -p udp --source 192.168.0.0/24 --dport ${toString ports.mqtt} -j nixos-fw-accept || true
    iptables -D nixos-fw -p tcp --source 127.0.0.0/8 --dport ${toString ports.mqtt} -j nixos-fw-accept || true
    iptables -D nixos-fw -p udp --source 127.0.0.0/8 --dport ${toString ports.mqtt} -j nixos-fw-accept || true
  '';

}