{ config, ports, ... }:
{

  services.alloy = {
    enable = true;
    extraFlags = [
      "--server.http.listen-addr=127.0.0.1:${toString ports.alloy}"
    ];
  };

  environment.etc."alloy/config.alloy".text = ''
    loki.relabel "journal" {
      forward_to = []

      rule {
        source_labels = ["__journal__systemd_unit"]
        target_label  = "unit"
      }
    }

    loki.source.journal "read"  {
      forward_to    = [loki.write.endpoint.receiver]
      relabel_rules = loki.relabel.journal.rules
      labels        = {
        component = "loki.source.journal",
        job = "systemd-journal",
        host = "${config.networking.hostName}",
      }
    }
    
    loki.write "endpoint" {
      endpoint {
        url = "http://${config.gradient.const.wireguard.addresses.gradientnet.asiyah}:${toString config.gradient.hosts.asiyah.ports.victorialogs}/insert/loki/api/v1/push"
      }
    }
  '';

  networking.firewall.interfaces.gradientnet.allowedTCPPorts = [
    ports.alloy
  ];

}