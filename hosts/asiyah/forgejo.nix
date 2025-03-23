{ config, pkgs, ... }:
let
  ports = import ./misc/service-ports.nix;
  repositoryRoot = "/data/repositories";
  lfsRoot = "/data/lfs";
in
{

  systemd.tmpfiles.settings."10-forgejo.conf" =
  let
    rule = {
      user = config.services.forgejo.user;
      group = config.services.forgejo.group;
      mode = "0750";
    };
  in
  {
    ${repositoryRoot}.d = rule;
    ${lfsRoot}.d = rule;
  };

  services.forgejo = {
    inherit repositoryRoot;
    enable = true;
    package = pkgs.forgejo;
    useWizard = false;

    lfs.enable = true;
    lfs.contentDir = lfsRoot;

    database = {
      type = "postgres";
      port = ports.postgresql;
    };

    secrets = {

    };

    settings = {

      session.COOKIE_SECURE = true;
      ui.SHOW_USER_EMAIL = false;

      DEFAULT = {
        APP_NAME = "Gradient Git";
        RUN_MODE = "prod";
      };

      repository = {
        DISABLE_STARS = true; # self-hosting so, doesn't make sense
      };

      oauth2_client = {
        USERNAME = "nickname";
        ENABLE_AUTO_REGISTRATION = true;
        REGISTER_EMAIL_CONFIRM = false;
        OPENID_CONNECT_SCOPES = "email profile";
        ACCOUNT_LINKING = "login";
      };

      server = {
        # Might enable this at some point
        DISABLE_SSH = true;
        HTTP_PORT = ports.forgejo;
        DOMAIN = "git.gradient.moe";
        ROOT_URL = "https://git.gradient.moe/";
      };

      service = {
        DISABLE_REGISTRATION = false;
        ALLOW_ONLY_EXTERNAL_REGISTRATION = true;
        ENABLE_INTERNAL_SIGNIN = false;
        ENABLE_NOTIFY_EMAIL = false;
        DEFAULT_KEEP_EMAIL_PRIVATE = true;
        WHITELISTED_URIS = "";
      };

      "service.explore" = {
        DISABLE_USERS_PAGE = true;
      };

      # TODO: add redis cache or something

      mailer = {
        # fuck that noise
        ENABLED = false;
      };

      # NOT actually oidc
      openid = {
        ENABLE_OPENID_SIGNIN = false;
        ENABLE_OPENID_SIGNUP = false;
      };

    };
  };

}