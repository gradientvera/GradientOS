{ config, ports, pkgs, ... }:
let
  secrets = config.sops.secrets;
in
{

  services.grafana = {
    enable = true;
    declarativePlugins = with pkgs.grafanaPlugins; [
      victoriametrics-metrics-datasource
      victoriametrics-logs-datasource
      yesoreyeram-infinity-datasource
      grafana-mqtt-datasource
    ];
    settings = {

      server = {
        protocol = "http";
        domain = "grafana.gradient.moe";
        # Reverse proxy URL so oauth2 redirect url works
        root_url = "https://%(domain)s/";
        serve_from_sub_path = false;
        http_port = ports.grafana;
        http_addr = "127.0.0.1";
      };

      security.secret_key = "$__file{${secrets.grafana-secret-key.path}}";

      database = {
        type = "postgres";
        user = "grafana";
        name = "grafana";
        ssl_mode = "disable";
        host = "127.0.0.1:${toString ports.postgresql}";
      };

      users = {
        allow_sign_up = false;
        # Respect user choice!
        default_theme = "system";
      };

      auth = {
        # Force login through kanidm
        disable_login_form = true;
      };

      # https://grafana.com/docs/grafana/next/setup-grafana/configure-security/configure-authentication/generic-oauth/
      "auth.generic_oauth" = {
        enabled = true;
        name = "KanIDM";
        client_id = "grafana";
        client_secret = null;
        scopes = "openid,email,profile,groups";
        auth_style = "InParams";
        use_pkce = true;
        auto_login = true;
        allow_signup = true;
        use_refresh_token = true;
        auth_url = "https://identity.gradient.moe/ui/oauth2";
        token_url = "https://identity.gradient.moe/oauth2/token";
        api_url = "https://identity.gradient.moe/oauth2/openid/grafana/userinfo";
        login_attribute_path = "preferred_username";
        groups_attribute_path = "groups";
        role_attribute_path = "contains(grafana_role[*], 'GrafanaAdmin') && 'GrafanaAdmin' || contains(grafana_role[*], 'Admin') && 'Admin' || contains(grafana_role[*], 'Editor') && 'Editor' || 'Viewer'";
        allow_assign_grafana_admin = true;
      };

    };

    provision = {
      enable = true;
      datasources.settings = {
        deleteDatasources = [
          {
            name = "VictoriaMetrics";
            orgId = 1;
          }
          {
            name = "VictoriaLogs";
            orgId = 1;
          }
          {
            name = "Prometheus";
            orgId = 1;
          }
          {
            name = "Infinity";
            orgId = 1;
          }
          {
            name = "MQTT";
            orgId = 1;
          }
        ];

        datasources = [
          {
            name = "VictoriaMetrics";
            orgId = 1;
            type = "victoriametrics-metrics-datasource";
            access = "proxy";
            basicAuth = false;
            withCredentials = false;
            url = "http://127.0.0.1:${toString ports.victoriametrics}";
            isDefault = true;
            editable = false;
          }
          {
            name = "VictoriaLogs";
            orgId = 1;
            type = "victoriametrics-logs-datasource";
            access = "proxy";
            basicAuth = false;
            withCredentials = false;
            url = "http://127.0.0.1:${toString ports.victorialogs}";
            editable = false;
          }
          {
            name = "Prometheus";
            orgId = 1;
            type = "prometheus";
            access = "proxy";
            basicAuth = false;
            withCredentials = false;
            url = "http://127.0.0.1:${toString ports.victoriametrics}";
            editable = false;
          }
          {
            name = "Infinity";
            orgId = 1;
            type = "yesoreyeram-infinity-datasource";
            url = "__IGNORE_URL__";
            basicAuth = false;
            withCredentials = false;
            jsonData = {
              global_queries = [];
              oauthPassThru = false;
              auth_method = "none";
            };
            editable = false;
          }
          {
            name = "MQTT";
            orgId = 1;
            type = "grafana-mqtt-datasource";
            access = "proxy";
            basicAuth = false;
            withCredentials = false;
            url = "tcp://127.0.0.1:${toString ports.mqtt}";
            editable = false;
          }
        ];
      };
    };
  };

  systemd.services.grafana = {
    wants = [ "postgresql.service" ];
    after = [ "postgresql.service" ];
  };

}