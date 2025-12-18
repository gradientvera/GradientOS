{ config, ... }:
{

  # Read nginx logs
  systemd.services.alloy.serviceConfig.SupplementaryGroups = [
    "nginx"
  ];

  environment.etc."alloy/nginx.alloy".text = ''
    loki.source.file "nginx_access_logs" {
      targets = [
        { __path__ = "/var/log/nginx/access.log", "type" = "access", "component" = "loki.source.file", "job" = "nginx_access_logs", "unit" = "nginx.service", "host" = "${config.networking.hostName}" },
      ]
      forward_to = [loki.process.nginx_access_logs_process.receiver]
    }

    loki.process "nginx_access_logs_process" {

      stage.regex {
        expression = "^(?P<http_host>\\S+) (?P<remote_ip>\\S+) - (?P<remote_user>\\S+) \\[(?P<time_local>[^\\]]+)\\] \"(?P<http_method>\\S+) (?P<http_request>[^\"]+) HTTP/(?P<http_version>\\S+)\" (?P<http_status>\\d+) (?P<http_body_bytes_sent>\\d+) \"(?P<http_referer>[^\"]*)\" \"(?P<http_user_agent>[^\"]*)\""
        labels_from_groups = true
      }

      stage.timestamp {
        source = "time_local"
        format = "02/Jan/2006:15:04:05 -0700"
        location = "Local"
      }

      forward_to = [loki.write.endpoint.receiver]

    }
  '';

}