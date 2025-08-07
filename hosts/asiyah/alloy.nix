{ config, ... }:
{

  # Read nginx logs
  systemd.services.alloy.serviceConfig.SupplementaryGroups = [
    "nginx"
  ];

  environment.etc."alloy/nginx.alloy".text = ''
    loki.source.file "nginx_access_logs" {
      targets = [
        { __path__ = "/var/log/nginx/access.log", "type" = "access" },
      ]
      forward_to = [loki.process.nginx_access_logs_process.receiver]
    }

    loki.process "nginx_access_logs_process" {
      stage.static_labels {
        values = {
          component = "loki.source.file",
          job = "nginx_access_logs",
          unit = "nginx.service",
          host = "${config.networking.hostName}",
        }
      }

      stage.regex {
        expression = "^(?P<remote_ip>\\S+) - (?P<remote_user>\\S+) \\[(?P<time_local>[^\\]]+)\\] \"(?P<http_method>\\S+) (?P<http_request>[^\"]+) HTTP/(?P<http_version>\\S+)\" (?P<http_status>\\d+) (?P<http_body_bytes_sent>\\d+) \"(?P<http_referer>[^\"]*)\" \"(?P<http_user_agent>[^\"]*)\""
      }

      stage.timestamp {
        source = "time_local"
        format = "01/Aug/2006:06:00:00 +0200"
        location = "Local"
      }

      stage.labels {
        values = {
          remote_ip = "",
          remote_user = "",
          time_local = "",
          time_local_extracted = "",
          http_method = "",
          http_request = "",
          http_version = "",
          http_status = "",
          http_body_bytes_sent = "",
          http_referer = "",
          http_user_agent = "",
        }
      }

      forward_to = [loki.write.endpoint.receiver]
    }
  '';

}