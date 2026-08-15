{ ports, ... }:
{

  services.gatus = {
    enable = true;
    # See https://gatus.io/docs and https://github.com/TwiN/gatus#configuration-1
    settings = {
      web = {
        address = "127.0.0.1";
        port = ports.gatus;
      };

      ui = {
        title = "Health Dashboard | Constellation Services";
        header = "Constellation";
        link = "https://homepage.constellation.moe";
        logo = "https://constellation.moe/images/favicon.svg";
        favicon.default = "https://constellation.moe/images/favicon.svg";
        description = "Uptime and health status for the Constellation and Gradient services.";
        dashboard-subheading = "";
      };

      storage = {
        type = "sqlite";
        path = "/var/lib/gatus/data.db";
        caching = true;
      };

      endpoints = [
        {
          name = "constellation.moe";
          url = "https://constellation.moe";
          interval = "5m";
          conditions = [
            "[STATUS] == 200"
            "[CONNECTED] == true"
            "[CERTIFICATE_EXPIRATION] > 48h"
            "[DOMAIN_EXPIRATION] > 48h"
          ];
        }

        {
          name = "gradient.moe";
          url = "https://gradient.moe";
          interval = "5m";
          conditions = [
            "[STATUS] == 200"
            "[CONNECTED] == true"
            "[CERTIFICATE_EXPIRATION] > 48h"
            "[DOMAIN_EXPIRATION] > 48h"
          ];
        }

        {
          name = "Jellyfin";
          url = "http://jellyfin.constellation.moe/health";
          interval = "5m";
          conditions = [
            "[STATUS] == 200"
            "[BODY] == Healthy"
          ];
        }
      ];
    };
  };

}
