{ config, pkgs, ... }:
let
  secrets = config.sops.secrets;
  ports = import ./misc/service-ports.nix;
  identityCert = config.security.acme.certs."identity.gradient.moe";
in
{

  services.kanidm = {
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
      extraJsonFile = secrets.kanidm-provisioning.path;
    };
  };

  # Allow kanidm to read secret, apparently the NixOS module does not set this???
  systemd.services.kanidm.serviceConfig.BindReadOnlyPaths = [ secrets.kanidm-provisioning.path ];

  # Allow let's encrypt certificate to be read by acme group
  security.acme.certs."identity.gradient.moe" = {
    reloadServices = [ "kanidm.service" ];
    postRun = ''
      chmod 750 fullchain.pem
      chmod 750 key.pem
    '';
  };

  # Add kanidm system user to acme group
  users.users.kanidm.extraGroups = [
    identityCert.group
  ];

  environment.systemPackages = [
    pkgs.kanidm
  ];

}