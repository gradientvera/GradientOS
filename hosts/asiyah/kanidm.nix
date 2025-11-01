{ config, pkgs, ... }:
let
  secrets = config.sops.secrets;
  ports = config.gradient.currentHost.ports;
  identityCert = config.security.acme.certs."identity.gradient.moe";
in
{

  # KanIDM Learning resources:
  # https://kanidm.github.io/kanidm/stable/

  services.kanidm = {
    package = pkgs.kanidmWithSecretProvisioning_1_7;

    enableServer = true;
    enableClient = true;

    serverSettings = {
      domain = "identity.gradient.moe";
      origin = "https://identity.gradient.moe";
      bindaddress = "127.0.0.1:${toString ports.kanidm}";
      ldapbindaddress = "127.0.0.1:${toString ports.kanidm-ldap}";
      trust_x_forward_for = true;

      online_backup.versions = 7;

      # Use auto-generated let's encrypt certificate
      tls_key = "/var/lib/acme/identity.gradient.moe/key.pem";
      tls_chain = "/var/lib/acme/identity.gradient.moe/fullchain.pem";
    };

    clientSettings = {
      uri = "https://identity.gradient.moe";
      verify_ca = true;
      verify_hostnames = true;
    };

    provision = {
      enable = true;
      autoRemove = true;
      adminPasswordFile = secrets.kanidm-admin-password.path;
      idmAdminPasswordFile = secrets.kanidm-idm-admin-password.path;
      extraJsonFile = secrets.kanidm-provisioning.path;
      systems.oauth2 = {
        
        constellation-oauth2-proxy = {
          public = true;
          displayName = "Constellation Internal Services";
          originLanding = "https://polycule.constellation.moe";
          originUrl = "https://polycule.constellation.moe/oauth2/callback";
          enableLocalhostRedirects = true;
          scopeMaps = {
            # Only allow constellation group members to access
            "constellation" = [
              "openid"
              "email"
              "profile"
              "groups"
            ];
          };  
        };

        home-assistant = {
          public = true;
          displayName = "Home Assistant Provider";
          originLanding = "https://hass.gradient.moe/";
          # As per https://github.com/christiaangoossens/hass-oidc-auth
          originUrl = "https://hass.gradient.moe/auth/oidc/callback";
          enableLegacyCrypto = true; # Needs RS256 apparently...
          enableLocalhostRedirects = true;
          scopeMaps = {
            # Only allow household group members to access
            "household" = [
              "openid"
              "email"
              "profile"
              "groups"
            ];
          };  
        };

        forgejo = {
          public = true;
          displayName = "Gradient Git";
          originLanding = "https://git.gradient.moe/user/login";
          originUrl = "https://git.gradient.moe/user/oauth2/kanidm/callback";
          enableLocalhostRedirects = true;
          preferShortUsername = true; # important or forgejo eats your face
          scopeMaps = {
            # Only allow forgejo group members to access
            "forgejo-users" = [
              "openid"
              "email"
              "profile"
              "groups"
            ];
          };  
        };

        # https://kanidm.github.io/kanidm/stable/integrations/oauth2/examples.html#grafana
        grafana = {
          public = true;
          displayName = "Grafana";
          originLanding = "https://grafana.gradient.moe";
          originUrl = "https://grafana.gradient.moe/login/generic_oauth";
          enableLocalhostRedirects = false;
          preferShortUsername = true;
          scopeMaps = {
            # Only allow... yes, you get it by now I imagine!
            "grafana-users" = [
              "openid"
              "email"
              "profile"
              "groups"
            ];
          };
          claimMaps = {
            "grafana_role" = {
              joinType = "array";
              valuesByGroup = {
                grafana-superadmins = [ "GrafanaAdmin" ];
                grafana-admins = [ "Admin" ];
                grafana-editors = [ "Editor" ];
              };
            };
          };
        };

        paperless = {
          public = true;
          displayName = "Paperless-ngx";
          originLanding = "https://paperless.gradient.moe";
          originUrl = "https://paperless.gradient.moe/accounts/oidc/kanidm/login/callback/";
          enableLocalhostRedirects = false;
          preferShortUsername = true;
          scopeMaps = {
            "paperless-users" = [
              "openid"
              "email"
              "profile"
              "groups"
            ];
          };
        };

      };
    };
  };

  # Allow kanidm to read secrets, apparently the NixOS module does not set this???
  systemd.services.kanidm.serviceConfig.BindReadOnlyPaths = [
    secrets.kanidm-provisioning.path
    secrets.kanidm-admin-password.path
    secrets.kanidm-idm-admin-password.path
  ];

  # Allow Let's Encrypt certificate to be read by acme group
  security.acme.certs."identity.gradient.moe" = {
    reloadServices = [ "kanidm.service" ];
    postRun = ''
      chmod 750 fullchain.pem
      chmod 750 key.pem
    '';
  };

  # Add kanidm system user to acme group so it can read the certificate
  users.users.kanidm.extraGroups = [
    identityCert.group
  ];

  # kanidm relies heavily on a couple CLI tools for management, so
  environment.systemPackages = [
    pkgs.kanidm
  ];

  networking.firewall.interfaces.podman0.allowedTCPPorts = with ports; [
    kanidm-ldap
  ];

}