/*

  Takes heavy inspiration from https://git.lix.systems/the-distro/infra/src/commit/f37ac9edf339710929556f3498a41b5375692c34/services/forgejo/default.nix
  Thank you, Lix infra team! <3

*/
{ config, pkgs, lib, ... }:
let
  ports = config.gradient.currentHost.ports;
  repositoryRoot = "/data/repositories";
  lfsRoot = "/data/lfs";
in
{

  systemd.tmpfiles.settings."10-forgejo.conf" =
  let
    rule = {
      user = config.services.forgejo.user;
      group = config.services.forgejo.group;
      mode = "0770";
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
      createDatabase = true;
    };

    secrets = {

    };

    settings = {

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
        LANDING_PAGE = "explore";
        HTTP_PORT = ports.forgejo;
        DOMAIN = "git.gradient.moe";
        ROOT_URL = "https://git.gradient.moe/";
      
        # SSH support
        DISABLE_SSH = false;
        START_SSH_SERVER = true;
        SSH_DOMAIN = "ssh.gradient.moe"; # Not proxied through cloudflare... TODO: figure out a better solution?
        BUILTIN_SSH_SERVER_USER = "git";
        SSH_LISTEN_HOST = "0.0.0.0";
        SSH_PORT = ports.forgejo-ssh;
        SSH_SERVER_HOST_KEYS = "${config.sops.secrets.forgejo-ssh-priv.path}";
        SSH_EXPOSE_ANONYMOUS = false;
      };

      ui = {
        SHOW_USER_EMAIL = false;
        DEFAULT_SHOW_FULL_NAME = false;
      };

      session = {
        COOKIE_SECURE = true;
        PROVIDER = "db";  
        PROVIDER_CONFIG = "";
        SESSION_LIFE_TIME = 86400 * 5;
      };

      service = {
        DISABLE_REGISTRATION = false;
        ALLOW_ONLY_EXTERNAL_REGISTRATION = true;
        ENABLE_INTERNAL_SIGNIN = false;
        ENABLE_NOTIFY_EMAIL = false;
        DEFAULT_KEEP_EMAIL_PRIVATE = true;
        WHITELISTED_URIS = "";
      };

      cache = {
        ADAPTER = "redis";
        HOST = "network=unix,addr=${config.services.redis.servers.forgejo.unixSocket},db=1";
        ITEM_TTL = "72h";
      };

      "service.explore" = {
        DISABLE_USERS_PAGE = true;
      };

      mailer = {
        # fuck that noise
        ENABLED = false;
      };

      # NOT actually oidc
      openid = {
        ENABLE_OPENID_SIGNIN = false;
        ENABLE_OPENID_SIGNUP = false;
      };

      actions = {
        ENABLED = true;
        DEFAULT_ACTIONS_URL = "https://git.gradient.moe";
      };

    };
  };

  services.gitea-actions-runner = {
    package = pkgs.forgejo-runner;
    instances.asiyah = {
      enable = true;
      name = "asiyah";
      url = "127.0.0.1:${toString ports.forgejo}";
      tokenFile = config.sops.secrets.forgejo-runner-token.path;
      labels = [
        "docker:docker://alpine:latest"
        
        "ubuntu-latest:docker://ubuntu:latest"
        "ubuntu-24.04:docker://ubuntu:noble"
        "ubuntu-22.04:docker://ubuntu:jammy"

        "debian-latest:docker://debian:latest"
        "debian-12.10:docker://debian:bookworm"
        "debian-11.11:docker://debian:bullseye"

        "alpine-latest:docker://alpine:latest"
        "alpine-3.21:docker://alpine:3.21"
        "alpine-3.20:docker://alpine:3.20"
      ];
    };
  };

  systemd.services.forgejo = {
    serviceConfig = {
      # Allow binding to port below 1024, for ssh
      AmbientCapabilities = [ "CAP_NET_BIND_SERVICE" ];
      CapabilityBoundingSet = [ "CAP_NET_BIND_SERVICE" ];
      
      # Allow using git user
      PrivateUsers = lib.mkForce false;
    };

    # Prevent race conditions with sshd in case of misconfiguration
    wants = [ "sshd.service" "postgresql.service" "kanidm.service" "redis-forgejo.service" ];
    after = [ "sshd.service" "postgresql.service" "kanidm.service" "redis-forgejo.service" ];
  };

  services.redis.servers.forgejo = {
    enable = true;
    user = config.services.forgejo.user;
    save = [];
    openFirewall = false;
    port = ports.redis-forgejo;
  };

  users.users.git = {
    isSystemUser = true;
    group = config.users.groups.git.name;
    extraGroups = [ "forgejo" ];
    createHome = false;
  };

  users.groups.git = {};

  networking.firewall.allowedTCPPorts = [
    ports.forgejo-ssh
  ];

  environment.systemPackages = [
    # For CLI management
    config.services.forgejo.package
  ];

}