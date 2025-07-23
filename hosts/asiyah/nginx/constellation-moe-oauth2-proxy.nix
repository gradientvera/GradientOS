{ config, ... }:
let
  secrets = config.sops.secrets;
  ports = config.gradient.currentHost.ports;
in {

  # TODO: Make this a container so we can have multiple instances of oauth2_proxy?
  # TODO-Followup: Might actually not be needed with kanidm, just use groups maybe?

  # OAuth2 Learning resources:
  # https://auth0.com/intro-to-iam/what-is-oauth-2
  # https://kanidm.github.io/kanidm/stable/integrations/oauth2.html
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
    redirectURL = "https://polycule.constellation.moe/oauth2/callback";
    oidcIssuerUrl = "https://identity.gradient.moe/oauth2/openid/constellation-oauth2-proxy";
    profileURL = "https://identity.gradient.moe/oauth2/openid/constellation-oauth2-proxy/userinfo";
    extraConfig.code-challenge-method = "S256";

    # Needed for things that use header auth.
    setXauthrequest = true;

    keyFile = secrets.oauth2-proxy-secrets.path;
    reverseProxy = true;
    cookie.refresh = "14m";
    cookie.expire = "720h0m0s";
    cookie.secure = true;
    cookie.httpOnly = false;
    cookie.domain = ".constellation.moe";
    cookie.name = "__Secure-oauth2_proxy_constellation";
    extraConfig = {
      pass-user-headers = "true";
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
    wants = [ "redis-oauth2.service" "kanidm.service" "nginx.service" ];
    after = [ "redis-oauth2.service" "kanidm.service" "nginx.service" ];
  };

  networking.firewall.allowedTCPPorts = with ports; [ oauth2-proxy ];

}