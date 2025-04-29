{ config, ... }:
let
  ports = config.gradient.currentHost.ports;
in
{

  services.paperless = {
    enable = true;
    exporter.enable = true;
    database.createLocally = true;

    address = "127.0.0.1";
    port = ports.paperless;

    consumptionDirIsPublic = true;

    environmentFile = config.sops.secrets.paperless-env.path;
    passwordFile = config.sops.secrets.paperless-admin-password.path;
    settings = {
      PAPERLESS_URL = "https://paperless.gradient.moe";

      PAPERLESS_APPS = "allauth.socialaccount.providers.openid_connect";

      PAPERLESS_SOCIALACCOUNT_PROVIDERS = builtins.toJSON ({
        openid_connect = {
          OAUTH_PKCE_ENABLED = true;
          APPS = [
            {
              provider_id = "kanidm";
              name = "Gradient Identity";
              client_id = "paperless";
              settings = {
                server_url = "https://identity.gradient.moe/oauth2/openid/paperless/.well-known/openid-configuration";
                oauth_pkce_enabled = true;
              };
            }
          ];
        };
      });

      PAPERLESS_SOCIAL_AUTO_SIGNUP = true;
      PAPERLESS_SOCIALACCOUNT_ALLOW_SIGNUPS = true;
      PAPERLESS_ACCOUNT_ALLOW_SIGNUPS = false;
      PAPERLESS_ACCOUNT_EMAIL_VERIFICATION = "none";
      PAPERLESS_DISABLE_REGULAR_LOGIN = true;
      PAPERLESS_REDIRECT_LOGIN_TO_SSO = true;
      PAPERLESS_ACCOUNT_SESSION_REMEMBER = true;

      PAPERLESS_OCR_LANGUAGE = "spa+eng";
      PAPERLESS_TIKA_ENABLED = "true";
      PAPERLESS_TIKA_ENDPOINT = "http://127.0.0.1:${toString ports.tika}";
      PAPERLESS_TIKA_GOTENBERG_ENDPOINT = "http://127.0.0.1:${toString ports.gotenberg}";

      PAPERLESS_TASK_WORKERS = 4;
      PAPERLESS_THREADS_PER_WORKER = 4;

      PAPERLESS_ENABLE_NLTK = true;

      PAPERLESS_USE_X_FORWARD_HOST = true;
      PAPERLESS_USE_X_FORWARD_PORT = true;
      PAPERLESS_PROXY_SSL_HEADER = ''["HTTP_X_FORWARDED_PROTO", "https"]'';
    };
  };

  services.tika = {
    enable = true;
    port = ports.tika;
    enableOcr = true;
  };

  services.gotenberg = {
    enable = true;
    port = ports.gotenberg;

    # libreoffice.autoStart = true;

    # It's just broken--
    # chromium.autoStart = true;
    # chromium.disableJavascript = true;
  };

}