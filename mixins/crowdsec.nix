{ config, pkgs, lib, ... }:
let
  addresses = config.gradient.const.addresses;
  gradientnet = config.gradient.const.wireguard.addresses.gradientnet;
  lilynet = config.gradient.const.wireguard.addresses.lilynet;
  asiyahPorts = config.gradient.hosts.asiyah.ports;
  ports = config.gradient.currentHost.ports;
  hostName = config.networking.hostName;
  isAsiyah = hostName == "asiyah";
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

    /*
    package = pkgs.crowdsec.overrideAttrs (prevAttrs: {
      # Add notification binaries to build here
      subPackages = prevAttrs.subPackages ++ [
        "cmd/notification-http"
      ];
    });
    */

    # Adds new parsing and detection behaviours
    hub.collections = [
      "crowdsecurity/linux"
      "crowdsecurity/auditd"
      "crowdsecurity/iptables"
      "crowdsecurity/linux-lpe"
    ] 
    ++ (if config.services.openssh.enable then [ "crowdsecurity/sshd" ] else [])
    ++ (if config.networking.wireguard.enable then [ "crowdsecurity/wireguard" ] else [])
    ++ (if config.services.home-assistant.enable then [ "crowdsecurity/home-assistant" ] else [])
    ++ (if config.services.nginx.enable then [
      "crowdsecurity/nginx"
      "crowdsecurity/http-dos"
    ] else []);

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
        decisions = [
          {
            duration = "4h";
            type = "ban";
          }
        ];
        filters = [
          "Alert.Remediation == true && Alert.GetScope() == 'Ip'"
        ];
        notifications = [
          # "http_discord"
        ];
        name = "default_ip_remediation";
        on_success = "break";
      }
      {
        decisions = [
          {
            duration = "4h";
            type = "ban";
          }
        ];
        filters = [
          "Alert.Remediation == true && Alert.GetScope() == 'Range'"
        ];
        notifications = [
          # "http_discord"
        ];
        name = "default_range_remediation";
        on_success = "break";
      }
    ];

    # What IPs and ranges to whitelist
    localConfig.parsers.s02Enrich = [
      {
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
            "${gradientnet.gradientnet}/24"
            "${lilynet.lilynet}/24"
          ];
        };
      }
    ];

    # TODO: Broken!
    /*
    localConfig.notifications = [
      # Discord notification
      {
        type = "http";
        name = "http_discord";
        # Taken from https://gist.github.com/bpbradley/6628f7c7486b46dfeefaa95a83373f01
        format = ''
          {
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
                "fields": [
                      {
                        "name": "Scenario",
                        "value": "`{{ .Scenario }}`",
                        "inline": "true"
                      },
                      {
                        "name": "IP",
                        "value": "[{{.Value}}](<https://www.whois.com/whois/{{.Value}}>)",
                        "inline": "true"
                      },
                      {
                        "name": "Ban Duration",
                        "value": "{{.Duration}}",
                        "inline": "true"
                      },
                      {{if $alert.Source.Cn -}}
                      { 
                        "name": "Country",
                        "value": "{{$alert.Source.Cn}} :flag_{{ $alert.Source.Cn | lower }}:",
                        "inline": "true"
                      }
                      {{if $cti.Location.City -}}
                      ,
                      { 
                        "name": "City",
                        "value": "{{$cti.Location.City}}",
                        "inline": "true"
                      },
                      { 
                        "name": "Maliciousness",
                        "value": "{{mulf $cti.GetMaliciousnessScore 100 | floor}} %",
                        "inline": "true"
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
        group_threshold = 5;
        log_level = "info";
        method = "POST";
        headers = { Content-Type = "application/json"; };
        url = "\${CROWDSEC_DISCORD_WEBHOOK_URL}";
      }
    ];
    */

    settings.general = {
      # Needed for HTTP notifications
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

  systemd.services.crowdsec = {
    # Load secrets
    serviceConfig.EnvironmentFile = config.sops.secrets.crowdsec-env.path;
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