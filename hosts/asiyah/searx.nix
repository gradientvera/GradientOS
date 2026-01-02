{ config, lib, pkgs, ports, ... }:
let
  ports = config.gradient.currentHost.ports;
  faviconSettings = (pkgs.writeText "favicons.toml" ''
    [favicons]
    cfg_schema = 1

    [favicons.cache]
    db_url = "/var/cache/searxng/faviconcache.db"
    LIMIT_TOTAL_BYTES = 10737418240 # 10 GB
    HOLD_TIME = 5184000

    [favicons.proxy.resolver_map]
    "duckduckgo" = "searx.favicons.resolvers.duckduckgo"
  '');
in
{

  services.searx = {
    enable = true;
    package = pkgs.master.searxng;
    configureUwsgi = false;
    redisCreateLocally = true;
    environmentFile = config.sops.secrets.searx.path;
    uwsgiConfig = {
      http = ":${toString ports.searx}";
    };
    settings = {
      use_default_settings = true;

      general = {
        debug = false;
        instance_name = "Gradient SearXNG";
        enable_metrics = true;
      };

      ui = {
        static_use_hash = true;
        query_in_title = true;
        infinite_scroll = true;
        center_alignment = true;
      };

      search = {
        default_lang = "en";
        autocomplete = "duckduckgo";
        favicon_resolver = "duckduckgo";
        formats = [
          "html"
          "json"
        ];
      };

      server = {
        port = ports.searx;
        bind_address = "0.0.0.0";
        secret_key = "@SEARX_SECRET_KEY@";
        public_instance = false;
        image_proxy = true;
        http_protocol_version = "1.1";
        method = "GET";
      };

      outgoing = {
        enable_http2 = true;
        max_request_timeout = 15.0;
        request_timeout = 5.0;
        pool_connections = 200;
        pool_maxsize = 30;
        retries = 5;
        useragent_suffix = "gradient.moe";
        source_ips = [ "0.0.0.0" "::" ];
        # Uncomment when https://github.com/NixOS/nixpkgs/issues/476192 is fixed
        /*proxies = {
          "all://:" = [
            "socks5://127.0.0.1:${toString ports.proxy-vpn}"
            "socks5://127.0.0.1:${toString ports.proxy-vpn-uk}"
            "socks5:://${config.gradient.const.wireguard.addresses.gradientnet.asiyah}:${toString ports.microsocks}"
            "socks5:://${config.gradient.const.wireguard.addresses.gradientnet.briah}:${toString config.gradient.hosts.briah.ports.microsocks}"
          ];
        };*/
      };

      enabled_plugins = [
        "Basic Calculator"
        "Hash plugin"
        "Self Information"
        "Tracker URL remover"
        "Unit converter plugin"
        #"Ahmia blacklist"  # activation depends on outgoing.using_tor_proxy
        "Infinite scroll"
        "Hostnames plugin"
        "Open Access DOI rewrite"
        #"Tor check plugin"
      ];

      hostnames = {
        replace = {
          "(.*\.)?reddit\.com$" = "old.reddit.com";
          "(.*\.)?redd\.it$"    = "old.reddit.com";
        };
        remove = [
          "(.*\.)?redditmedia.com$"
          "(.*\.)?facebook.com$"
          "(.*\.)?softonic.com$"
          "(.*\.)?nixos.wiki$"
        ];
        high_priority = [
          "(.*\.)?wikipedia.com$"
          "(.*\.)?reddit.com$"
          "(.*\.)?github.com$"

          # For wiki articles
          "(.*\.)?nixos.org$"
          "(.*\.)archlinux.org$"
        ];
        low_priority = [

        ];
      };

      valkey = {
        url = "unix://${config.services.redis.servers.searx.unixSocket}";
      };  

      # Uncomment below for TOR proxy support.
      /*outgoing.proxies = {
        http  = [ "socks5://127.0.0.1:${toString ports.tor}" ];
        https = [ "socks5://127.0.0.1:${toString ports.tor}" ];
      };*/

    };
    limiterSettings = {
      "botdetection.ip_limit" = {
        link_token = false;
      };

      "botdetection.ip_lists" = {
        block_ip = [];
        pass_ip = [];
      };
    };
  };

  systemd.services.searx-init-favicon = {
    wants = [ "network-online.target" ];
    after = [ "network-online.target" ];
    description = "Initialise Searxng favicon settings";
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      User = "searx";
      RuntimeDirectory = "searx";
      RuntimeDirectoryMode = "750";
    };
    script = ''
      cd /run/searx

      umask 077
      cp --no-preserve=mode ${faviconSettings} favicons.toml
    '';
  };

  systemd.services.searx-init = {
    wants = [ "searx-init-favicon.service" "network-online.target" ];
    after = [ "searx-init-favicon.service" "network-online.target" ];
  };

  systemd.services.searx = {
    wants = [ "redis-searx.service" "network-online.target" ];
    after = [ "redis-searx.service" "network-online.target" ];
  };

  systemd.tmpfiles.settings."10-searxng.conf" = {
    "/var/cache/searxng".d = {
      user = config.users.users.searx.name;
      group = config.users.users.searx.group;
      mode = "0770";
    };
  };

  networking.firewall.interfaces.gradientnet.allowedTCPPorts = [ ports.searx ];
  networking.firewall.interfaces.gradientnet.allowedUDPPorts = [ ports.searx ];

}