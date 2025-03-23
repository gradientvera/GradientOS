{ config, ... }:
let
  secrets = config.sops.secrets;
  ports = import ../misc/service-ports.nix;
in {

  # TODO: Make this a container so we can have multiple instances of oauth2_proxy?

  # OAuth2 Learning resources:
  # https://auth0.com/intro-to-iam/what-is-oauth-2
  # https://oauth2-proxy.github.io/oauth2-proxy/configuration/providers/openid_connect/

  services.oauth2-proxy = {
    enable = true;
    httpAddress = "http://127.0.0.1:${toString ports.oauth2-proxy}";
    upstream = [ "http://127.0.0.1:${toString ports.nginx}" ];

    # -- github config --
    #redirectURL = "https://polycule.constellation.moe/oauth2/callback";
    #provider = "github";
    #github.org = "ConstellationNRV";
    #clientID = "05fb727827ad30eddf0d";

    # -- kanidm config --
    provider = "oidc";
    clientID = "constellation-oauth2-proxy";
    clientSecret = "proxy"; # Not actually a secret! Uses PKCE
    redirectURL = "https://polycule.constellation.moe/oauth2/callback";
    oidcIssuerUrl = "https://identity.gradient.moe/oauth2/openid/constellation-oauth2-proxy";
    profileURL = "https://identity.gradient.moe/oauth2/openid/constellation-oauth2-proxy/userinfo";
    extraConfig.code-challenge-method = "S256";

    keyFile = secrets.oauth2-proxy-secrets.path;
    reverseProxy = true;
    cookie.refresh = "1m";
    cookie.secure = true;
    cookie.httpOnly = false;
    cookie.domain = ".constellation.moe";
    extraConfig = {
      session-store-type = "redis";
      redis-connection-url = "redis://127.0.0.1:${toString ports.redis-oauth2}/0";
    };
    nginx.domain = "polycule.constellation.moe";
  };

  services.redis.servers.oauth2 = {
    enable = true;
    databases = 1;
    openFirewall = false;
    port = ports.redis-oauth2;
  };

  systemd.services.oauth2-proxy = {
    after = [ "redis-oauth2.service" ];
    wants = [ "redis-oauth2.service" ];
  };

  networking.firewall.allowedTCPPorts = with ports; [ oauth2-proxy ];

}