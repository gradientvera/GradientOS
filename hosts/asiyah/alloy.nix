{ ... }:
{

  # Read nginx logs
  systemd.services.alloy.serviceConfig.SupplementaryGroups = [
    "nginx"
  ];

  environment.etc."alloy/nginx.alloy".text = ''
    loki.source.file "nginx-logs" {
      targets = [
        { __path__ = "/var/log/nginx/access.log", "type" = "access" },  
        { __path__ = "/var/log/nginx/error.log", "type" = "error" },  
      ]
      forward_to = [loki.write.endpoint.receiver]
    }

  '';

}