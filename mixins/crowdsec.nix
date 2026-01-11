{ config, pkgs, lib, ... }:
let
  addresses = config.gradient.const.addresses;
  gradientnet = config.gradient.const.wireguard.addresses.gradientnet;
  lilynet = config.gradient.const.wireguard.addresses.lilynet;
  asiyahPorts = config.gradient.hosts.asiyah.ports;
  ports = config.gradient.currentHost.ports;
  hostName = config.networking.hostName;
  isAsiyah = hostName == "asiyah";
  writeYamlFile = (pkgs.formats.yaml {}).generate;
  etcDefaults = {
    enable = true;
    user = "crowdsec";
    group = "crowdsec";
    mode = "0770";
  };
in
{

  networking.firewall.interfaces.gradientnet.allowedTCPPorts = if isAsiyah then [
    asiyahPorts.crowdsec-lapi
    asiyahPorts.crowdsec-metrics
  ] else [
    ports.crowdsec-metrics
  ];

  services.crowdsec = {
    enable = true;
    openFirewall = false;
    autoUpdateService = true;

    # Adds new parsing and detection behaviours
    hub.collections = [
      "crowdsecurity/linux"
      "crowdsecurity/auditd"
      "crowdsecurity/iptables"
      "crowdsecurity/linux-lpe"
    ] 
    ++ (if config.services.openssh.enable then [ "crowdsecurity/sshd" ] else [])
    # Needs spammy option so disable it: ++ (if config.networking.wireguard.enable then [ "crowdsecurity/wireguard" ] else [])
    ++ (if config.services.home-assistant.enable then [ "crowdsecurity/home-assistant" ] else [])
    ++ (if config.services.nginx.enable then [
      "crowdsecurity/nginx"
      "crowdsecurity/http-dos"
    ] else []);

    hub.parsers = [
      "crowdsecurity/whitelists"
      "crowdsecurity/jellyfin-whitelist"
      "crowdsecurity/jellyseerr-whitelist"
      "crowdsecurity/calibre-web-whitelist"
    ];

    hub.postOverflows = [
      "crowdsecurity/auditd-nix-wrappers-whitelist-process"
    ];

    # Where to get logs from
    localConfig.acquisitions = [
      {
        source = "journalctl";
        journalctl_filter = [ "_TRANSPORT=journal" ];
        labels.type = "syslog";
      }
      {
        source = "journalctl";
        journalctl_filter = [ "_TRANSPORT=syslog" ];
        labels.type = "syslog";
      }
      {
        source = "journalctl";
        journalctl_filter = [ "_TRANSPORT=stdout" ];
        labels.type = "syslog";
      }
      {
        source = "journalctl";
        journalctl_filter = [ "_TRANSPORT=kernel" ];
        labels.type = "syslog";
      }
      {
        source = "file";
        filenames = [
          "/var/log/audit/*.log"
        ];
        labels.type = "auditd";
      }
    ]
    ++ (if config.services.nginx.enable then [
      {
        source = "file";
        filenames = [
          "/var/log/nginx/*.log"
        ];
        labels.type = "nginx";
      }
    ] else []);

    # What action to take for alerts
    localConfig.profiles = [
      {
        name = "default_ip_remediation";
        decisions = [
          {
            duration = "4h";
            type = "ban";
          }
        ];
        filters = [
          "Alert.Remediation == true && Alert.GetScope() == 'Ip'"
        ];
        notifications = lib.mkIf isAsiyah [
          "http_discord"
        ];
        on_success = "break";
      }
      {
        name = "default_range_remediation";
        decisions = [
          {
            duration = "4h";
            type = "ban";
          }
        ];
        filters = [
          "Alert.Remediation == true && Alert.GetScope() == 'Range'"
        ];
        notifications = lib.mkIf isAsiyah [
          "http_discord"
        ];
        on_success = "break";
      }
      {
        name = "pid_alert";
        filters = [
          "Alert.GetScope() == 'pid'"
        ];
        decisions = [];
        notifications = lib.mkIf isAsiyah [
          # "http_discord_pid"
        ];
        ## Please edit the above line to match your notification name
        on_success = "break";
      }
    ];

    settings.general = {
      # Needed for HTTP notifications
      config_paths.plugin_dir = lib.mkForce "/etc/crowdsec/plugins";
      plugin_config = {
        user = "crowdsec";
        group = "crowdsec";
      };
      api.server = if isAsiyah then {
        enable = true;
        listen_uri = "${gradientnet.asiyah}:${toString asiyahPorts.crowdsec-lapi}";
        trusted_ips = [
          "::1"
          "127.0.0.1"
          "${gradientnet.gradientnet}/24"
        ];
        auto_registration = {
          enabled = true;
          token = "\${CROWDSEC_AUTO_REGISTRATION_TOKEN}";
          allowed_ranges = [
            "127.0.0.0/24"
            "${gradientnet.gradientnet}/24"
          ];
        };
      } else {
        enable = false;
      };
      prometheus = {
        enabled = true;
        level = "full";
        listen_addr = gradientnet.${hostName};
        listen_port = asiyahPorts.crowdsec-metrics;
      };
    };

    settings.capi.credentialsFile = if isAsiyah then "/etc/crowdsec/online_api_credentials.yaml" else null;
    settings.lapi.credentialsFile = "/etc/crowdsec/local_api_credentials.yaml";
    settings.console.tokenFile = config.sops.secrets.crowdsec-console-token.path;
  };

  users.users.${config.services.crowdsec.user}.extraGroups = [ "nginx" "auditd" ];

  environment.etc = {
    "crowdsec/plugins/notification-http" = etcDefaults // {
      enable = isAsiyah;
      mode = "0700";
      source = "${pkgs.crowdsec}/bin/notification-http";
    };

    "crowdsec/postoverflows/s01-whitelist/myfqdns-whitelist.yaml" = etcDefaults // {
      source = writeYamlFile "crowdsec-parser-myfqdns-whitelist.yaml" {
        description = "Whitelist my own IPs";
        name = "myfqdns/whitelist";
        whitelist = {
          expression = [
            ''evt.Overflow.Alert.Source.IP in LookupHost("gradient.moe")''
            ''evt.Overflow.Alert.Source.IP in LookupHost("gradientvera.duckdns.org")''
          ];
        };
      };
    };

    "crowdsec/parsers/s02-enrich/myips-whitelist.yaml" = etcDefaults // {
      source = writeYamlFile "crowdsec-parser-myips-whitelist.yaml" {
        description = "Whitelist my own IPs";
        name = "myips/whitelist";
        whitelist = {
          ip = [
            addresses.briah
            addresses.briahv6
          ];
          cidr = [
            "10.0.0.0/8"
            "192.168.1.0/24"
            addresses.briahv6-cidr
            "${gradientnet.gradientnet}/24"
            "${lilynet.lilynet}/24"
          ];
        };
      };
    };

    "crowdsec/parsers/s02-enrich/path-whitelist.yaml" = etcDefaults // {
      source = writeYamlFile "crowdsec-parser-path-whitelist.yaml" {
        description = "Whitelist some reqiest paths";
        name = "paths/whitelist";
        filter = "evt.Meta.service == 'http' && evt.Meta.log_type in ['http_access-log', 'http_error-log']";
        whitelist = {
          reason = "Paths whitelist";
          expression = [
            # Mediarr
            "evt.Meta.http_status in ['200', '304'] && evt.Meta.http_verb == 'GET' && evt.Meta.http_path matches '^/(QuickConnect|Branding|Persons|Artists|Items|JellyfinEnhanced|JavaScriptInjector|JellyTweaks|PluginPages|System|UserViews|HomeScreen|Playback|CustomTabs|DisplayPreferences|Users|web|ui/oauth2|api/services|api/docker|api/widget|api/siteMonitor|api/v1/request|api/frigate).*'"
            "evt.Meta.http_status in ['200', '304'] && evt.Meta.http_verb == 'POST' && evt.Meta.http_path matches '^/(api/actions/runner.v1.RunnerService/FetchTask).*'"
          ];
        };
      };
    };

    "crowdsec/notifications/http_discord.yaml" = etcDefaults // {
      enable = isAsiyah;
      source = writeYamlFile "crowdsec-notification-http-discord.yaml" {
        type = "http";
        name = "http_discord";
        # Taken from https://gist.github.com/bpbradley/6628f7c7486b46dfeefaa95a83373f01
        format = ''
          {
            "username": "Crowdsec",
            "avatar_url": "https://avatars.githubusercontent.com/u/63284097",
            "embeds": [
              {
                {{range . -}}
                {{$alert := . -}}
                {{range .Decisions -}}
                {{- $cti := .Value | CrowdsecCTI  -}}
                "timestamp": "{{$alert.StartAt}}",
                "title": "Crowdsec Alert",
                "color": 16711680,
                "description": "Potential threat detected. View details in [Crowdsec Console](<https://app.crowdsec.net/cti/{{.Value}}>)",
                "url": "https://app.crowdsec.net/cti/{{.Value}}",
                {{if $alert.Source.Cn -}}
                "image": {
                  "url": "https://maps.geoapify.com/v1/staticmap?style=osm-bright-grey&width=600&height=400&center=lonlat:{{$alert.Source.Longitude}},{{$alert.Source.Latitude}}&zoom=8.1848&marker=lonlat:{{$alert.Source.Longitude}},{{$alert.Source.Latitude}};type:awesome;color:%23655e90;size:large;icon:industry|lonlat:{{$alert.Source.Longitude}},{{$alert.Source.Latitude}};type:material;color:%23ff3421;icontype:awesome&scaleFactor=2&apiKey={{env "GEOAPIFY_API_KEY"}}"
                },
                {{end}}
                "fields": [
                      {
                        "name": "Scenario",
                        "value": "`{{ .Scenario }}`",
                        "inline": true
                      },
                      {
                        "name": "IP",
                        "value": "[{{.Value}}](<https://www.whois.com/whois/{{.Value}}>)",
                        "inline": true
                      },
                      {
                        "name": "Ban Duration",
                        "value": "{{.Duration}}",
                        "inline": true
                      },
                      {{if $alert.Source.Cn -}}
                      { 
                        "name": "Country",
                        "value": "{{$alert.Source.Cn}} :flag_{{ $alert.Source.Cn | lower }}:",
                        "inline": true
                      }
                      {{if $cti.Location.City -}}
                      ,
                      { 
                        "name": "City",
                        "value": "{{$cti.Location.City}}",
                        "inline": true
                      },
                      { 
                        "name": "Maliciousness",
                        "value": "{{mulf $cti.GetMaliciousnessScore 100 | floor}} %",
                        "inline": true
                      }
                      {{end}}
                      {{end}}
                      {{if not $alert.Source.Cn -}}
                      { 
                        "name": "Location",
                        "value": "Unknown :pirate_flag:"
                      }
                      {{end}}
                      {{end -}}
                      {{end -}}
                      {{range . -}}
                      {{$alert := . -}}
                      {{range .Meta -}}
                        ,{
                        "name": "{{.Key}}",
                        "value": "{{ (splitList "," (.Value | replace "\"" "`" | replace "[" "" |replace "]" "")) | join "\\n"}}"
                      } 
                      {{end -}}
                      {{end -}}
                ]
              }
            ]
          }
        '';
        group_wait = "30s";
        group_threshold = 5;
        max_retry = 5;
        log_level = "info";
        method = "POST";
        headers = { Content-Type = "application/json"; };
        url = "https://discord.com/api/webhooks/\${CROWDSEC_DISCORD_WEBHOOK_CODE}";
      };
    };
  };

  systemd.services.crowdsec.serviceConfig = {
    # Load secrets
    EnvironmentFile = lib.mkAfter [ config.sops.secrets.crowdsec-env.path ];
    ReadWritePaths = lib.mkAfter [ config.sops.secrets.crowdsec-env.path ];
    # TODO: see what can we get away with rather than disabling everything 
    CapabilityBoundingSet=lib.mkForce [];
    DevicePolicy=lib.mkForce [];
    LockPersonality=lib.mkForce [];
    NoNewPrivileges=lib.mkForce [];
    PrivateDevices=lib.mkForce [];
    PrivateTmp=lib.mkForce [];
    PrivateUsers=lib.mkForce [];
    ProtectClock=lib.mkForce [];
    ProtectControlGroups=lib.mkForce [];
    ProtectHome=lib.mkForce [];
    ProtectHostname=lib.mkForce [];
    ProtectKernelLogs=lib.mkForce [];
    ProtectKernelModules=lib.mkForce [];
    ProtectKernelTunables=lib.mkForce [];
    ProtectProc=lib.mkForce [];
    ProtectSystem=lib.mkForce [];
    RemoveIPC=lib.mkForce [];
    RestrictAddressFamilies=lib.mkForce [];
    RestrictNamespaces=lib.mkForce [];
    RestrictRealtime=lib.mkForce [];
    RestrictSUIDSGID=lib.mkForce [];
    SystemCallArchitectures=lib.mkForce [];
    SystemCallFilter=lib.mkForce [];
  };

  # Auto-register machines
  systemd.services.crowdsec-registration = {
    partOf = [ "crowdsec.service" ];
    after = [ "crowdsec.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      User = config.services.crowdsec.user;
      Group = config.services.crowdsec.group;
      RemainAfterExit = true;
      EnvironmentFile = config.sops.secrets.crowdsec-env.path;
    };
    # Use cscli from environment, which already has the config file specified
    path = [ "/run/current-system/sw" ]; # ugly hack lol
    script = ''
      ${if isAsiyah then ''
      cscli bouncers add gradient --key $CROWDSEC_BOUNCER_API_KEY || echo "Done adding bouncer!"
      '' else ""}

      if [ ! -f ${config.services.crowdsec.settings.lapi.credentialsFile} ]; then
        touch ${config.services.crowdsec.settings.lapi.credentialsFile}
        echo "url: http://${gradientnet.asiyah}:${toString asiyahPorts.crowdsec-lapi}" >> ${config.services.crowdsec.settings.lapi.credentialsFile}
        echo "login: ${config.services.crowdsec.name}" >> ${config.services.crowdsec.settings.lapi.credentialsFile}
      fi

      cscli lapi register --machine ${config.services.crowdsec.name} --url http://${gradientnet.asiyah}:${toString asiyahPorts.crowdsec-lapi} --token $CROWDSEC_AUTO_REGISTRATION_TOKEN || echo "Done registering with LAPI!"
    '';
  };

  systemd.services.auto-crowdsec-unban = {
    enable = isAsiyah;
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    startAt = "*:0/5";
    serviceConfig = {
      Type = "simple";
      User = config.services.crowdsec.user;
      Group = config.services.crowdsec.group;
    };
    path = [ "/run/current-system/sw" ]; # same as above guh
    script = ''
      ipv4addr=$(curl -s https://api.ipify.org)
      ipv6addr=$(curl -s https://api6.ipify.org)
      cscli decisions remove -i $ipv4addr || echo "Done ipv4!"
      cscli decisions remove -i $ipv6addr || echo "Done ipv6!"
    '';
  };

  # Bouncer
  systemd.services.crowdsec-firewall-bouncer =
  let
    bouncerConfig = (pkgs.formats.yaml {}).generate "crowdsec-firewall-bouncer.yaml" ({
      mode = "iptables";
      update_frequency = "10s";
      scenarios_containing = [ "ssh" "http" ];
      scopes = [ "Ip" "Range" ];
      origins = [ "cscli" "crowdsec" "CAPI" "lists" ];
      api_url = "http://${gradientnet.asiyah}:${toString asiyahPorts.crowdsec-lapi}";
      api_key = "\${CROWDSEC_BOUNCER_API_KEY}";
      iptables_chains = [ "INPUT" ];
      ipset_type = "nethash";
      blacklists_ipv4 = "crowdsec-blacklists";
      blacklists_ipv6 = "crowdsec6-blacklists";
    });
  in
  {
    partOf = [ "crowdsec.service" ];
    after = [ "crowdsec.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig.EnvironmentFile = config.sops.secrets.crowdsec-env.path;
    serviceConfig.Restart = "always";
    # Dependencies of bouncer
    path = [ pkgs.ipset pkgs.iptables ];
    script = ''
      ${lib.getExe pkgs.crowdsec-firewall-bouncer} -c ${toString bouncerConfig}
    '';
  };

}

/*




*/