{ pkgs, lib, config, ... }:
let
  addresses = config.gradient.const.addresses;
  ports = config.gradient.currentHost.ports;
in {

  imports = [
    ./crp3092.nix
    ./gradientnet.nix
    ./gradient-moe.nix
    ./constellation-moe.nix
    ./constellation-homepage.nix
    ./constellation-moe-internal.nix
    ./constellation-moe-oauth2-proxy.nix
  ];

  services.nginx = {
    enable = true;
    defaultListen = [
      # HTTP
      { addr = "0.0.0.0"; port = ports.nginx; ssl = false; }
      { addr = "[::]"; port = ports.nginx; ssl = false; }

      # HTTPS
      { addr = "0.0.0.0"; port = ports.nginx-ssl; ssl = true; }
      { addr = "[::]"; port = ports.nginx-ssl; ssl = true; }
    ];

    appendHttpConfig = ''
      set_real_ip_from ${config.gradient.const.wireguard.addresses.gradientnet.gradientnet}/24;
      set_real_ip_from ${addresses.briah};
      set_real_ip_from ${addresses.briahv6};
      set_real_ip_from ${addresses.briahv6-cidr};
      real_ip_header X-Real-IP;
      real_ip_recursive on;

      map $preferredusername $xusername {
        ~^(\w+)@identity.gradient.moe $1;
        default $preferredusername;
      }
    '';

    # Redirect to main site for all incorrect subdomains
    virtualHosts."_" = {
      default = true;
      addSSL = true;
      enableACME = false;
      useACMEHost = "gradient.moe";
      serverName = ''""'';
      globalRedirect = "gradient.moe";
    };
  };

  security.acme = {
    acceptTerms = true;
    defaults = {
      email = "gradientvera+acme@outlook.com";
      dnsResolver = "1.1.1.1:53";
      # dnsProvider = "cloudflare"; # Apparently this default doesn't work lmao
      credentialFiles."CF_DNS_API_TOKEN_FILE" = config.sops.secrets.acme-cf-token.path;
    };
  };

  services.rsync.jobs.briah-acme = {
    sources = [
      config.security.acme.certs."gradient.moe".directory
      config.security.acme.certs."constellation.moe".directory
    ];
    destination = "root@${addresses.briah}:${config.users.users.acme.home}";
    # vera user for SSH to briah, nginx group to access certs
    user = "vera";
    group = "nginx";
    timerConfig = {
      # Every five minutes. A bit overkill but eh.
      OnCalendar = "*:0/5";
      Persistent = true;
    };
    settings = {
      # Syncs recursively, copy permissions and modification times
      archive = true;
      # Create destination folder if needed
      mkpath = true;
      # Delete files on destination that don't exist on the source anymore
      delete = true;
      # Compress data before transfer
      compress = true;
      # Change owner/group on destination (ACME user not available there)
      chown = "nginx:nginx";
      # Set SSH command, fix rsync being unable to find it otherwise
      rsh = "${lib.getExe pkgs.openssh}";
    };
  };


  networking.firewall.allowedTCPPorts = with ports; [
    nginx nginx-ssl
  ];
  networking.firewall.allowedUDPPorts = with ports; [
    nginx nginx-ssl 
  ];

}