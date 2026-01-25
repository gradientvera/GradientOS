{ config, lib, ... }:
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
    scope = "openid email profile groups";
    clientID = "constellation-oauth2-proxy";
    redirectURL = "https://polycule.constellation.moe/oauth2/callback";
    oidcIssuerUrl = "https://identity.gradient.moe/oauth2/openid/constellation-oauth2-proxy";
    profileURL = "https://identity.gradient.moe/oauth2/openid/constellation-oauth2-proxy/userinfo";
    extraConfig.code-challenge-method = "S256";

    # Needed for things that use header auth.
    setXauthrequest = true;

    keyFile = secrets.oauth2-proxy-secrets.path;
    reverseProxy = true;
    cookie.refresh = "167h59m0s";
    cookie.expire = "168h0m0s";
    cookie.secure = true;
    cookie.httpOnly = true;
    cookie.domain = ".constellation.moe";
    cookie.name = "__Secure-oauth2_proxy_constellation";
    extraConfig = {
      pass-basic-auth = "true";
      pass-user-headers = "true";
      whitelist-domain = ".constellation.moe";
    };
    nginx.domain = "polycule.constellation.moe";
  };

  systemd.services.oauth2-proxy = {
    wants = [ "kanidm.service" "nginx.service" "network-online.target" ];
    after = [ "kanidm.service" "nginx.service" "network-online.target" ];
    # Keep restarting OAuth2-Proxy no matter what
    startLimitIntervalSec = lib.mkForce 0;
    startLimitBurst = lib.mkForce 0;
    serviceConfig.Restart = lib.mkForce "always";
  };

  networking.firewall.allowedTCPPorts = with ports; [ oauth2-proxy ];

}