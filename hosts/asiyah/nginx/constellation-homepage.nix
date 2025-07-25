{ config, ports, ... }:
{

  services.homepage-dashboard = {
    enable = true;
    listenPort = ports.constellation-homepage;
    # Not needed, we secure this with the firewall, OAuth2 Proxy and Nginx reverse proxy.
    allowedHosts = "*";
    environmentFile = config.sops.secrets.constellation-homepage.path;
    settings = {
      title = "Constellation Homepage";
      favicon = "https://constellation.moe/images/favicon.svg";
      description = "Homepage for all the Constellation Internal Services.";
      language = "en";
      target = "_blank";
      headerStyle = "boxed";
      useEqualHeights = true;
      hideErrors = true;
      statusStyle = "dot";
      layout = [
        {
          "Utils" = {
            style = "row";
            columns = 4;
          };
        }
        {
          "Media" = {
            style = "row";
            columns = 5;
          };
        }
        {
          "Media Internal" = {
            style = "row";
            columns = 4;
          };
        }
      ];
      quicklaunch = {
        searchDescriptions = true;
        hideInternetSearch = false;
        showSearchSuggestions = true;
        hideVisitURL = false;
        provider = "custom";
        url = "https://search.constellation.moe/search?q=";
        suggestionUrl = "https://search.constellation.moe/autocompleter?q=";
        target = "_blank";
      };
    };
    widgets = [
      {
        logo = {
          icon = "https://constellation.moe/images/favicon.svg";
          href = "https://homepage.constellation.moe";
        };
      }
      {
        resources = {
          label = "System";
          cpu = true;
          memory = true;
          network = true;
          cputemp = true;
          uptime = true;
          units = "metric";
          disk = "/";
        };
      }
      {
        resources = {
          label = "Storage";
          disk = "/data";
        };
      }
      {
        search = {
          showSearchSuggestions = true;
          provider = "custom";
          url = "https://search.constellation.moe/search?q=";
          suggestionUrl = "https://search.constellation.moe/autocompleter?q=";
          target = "_blank";
        };
      }
    ];
    services = [
      {
        "Utils" = [
          {
            "Gradient Identity" = {
              description = "Kanidm, a modern and simple identity management platform written in rust.";
              href = "https://identity.gradient.moe/";
              icon = "sh-kanidm.svg";
              siteMonitor = "https://identity.gradient.moe/";
            };
          }
          {
            "SearXNG" = {
              description = "A free and open-source federated metasearch engine forked from Searx which does not collect information about users.";
              href = "https://search.constellation.moe/";
              icon = "sh-searxng.svg";
              siteMonitor = "http://127.0.0.1:${toString ports.searx}";
            };
          }
          {
            "Gradient Git" = {
              description = "A Free Software platform for collaboration and productivity in software development.";
              href = "https://git.gradient.moe/";
              icon = "sh-forgejo.svg";
              siteMonitor = "http://127.0.0.1:${toString ports.forgejo}";
              /* Does not work for some reason!
              widget = {
                type = "gitea";
                url = "http://127.0.0.1:${toString ports.forgejo}";
                key = "{{HOMEPAGE_VAR_FORGEJO_API_KEY}}";
              };*/
            };
          }
          {
            "Status" = {
              description = "Status page for Constellation Internal Services.";
              href = "https://status.constellation.moe/";
              icon = "sh-uptime-kuma.svg";
              siteMonitor = "http://127.0.0.1:${toString ports.uptime-kuma}";
              widget = {
                type = "uptimekuma";
                url = "http://127.0.0.1:${toString ports.uptime-kuma}";
                slug = "internal-constellation-services";
              };
            };
          }
        ];
      }
      {
        "Media" = [
          {
            "Jellyfin" = {
              description = "Media solution that lets you stream your own media to any device.";
              href = "https://jellyfin.constellation.moe/";
              icon = "sh-jellyfin.svg";
              server = "asiyah";
              container = "jellyfin";
              widget = {
                type = "jellyfin";
                url = "http://127.0.0.1:${toString ports.jellyfin-http}";
                key = "{{HOMEPAGE_VAR_JELLYFIN_API_KEY}}";
                enableBlocks = true;
                enableNowPlaying = false;
                enableMediaControl = false;
              };
            };
          }
          {
            "Jellyseerr" = {
              description = "Software application for managing requests for your media library.";
              href = "https://jellyseerr.constellation.moe/";
              icon = "sh-jellyseerr.svg";
              server = "asiyah";
              container = "jellyseerr";
              widget = {
                type = "jellyseerr";
                url = "http://127.0.0.1:${toString ports.jellyseerr}";
                key = "{{HOMEPAGE_VAR_JELLYSEERR_API_KEY}}";
              };
            };
          }
          {
            "Calibre" = {
              description = "The one stop solution for all your e-book needs. Comprehensive e-book software.";
              href = "https://calibre.constellation.moe/";
              icon = "sh-calibre.svg";
              server = "asiyah";
              container = "calibre";
              widget = {
                type = "calibreweb";
                url = "http://127.0.0.1:${toString ports.calibre-web-automated}";
                username = "{{HOMEPAGE_VAR_CALIBRE_USERNAME}}";
                password = "{{HOMEPAGE_VAR_CALIBRE_PASSWORD}}";
              };
            };
          }
          {
            "RomM" = {
              description = "A beautiful, powerful, self-hosted rom manager and player.";
              href = "https://romm.constellation.moe/";
              icon = "sh-romm.svg";
              server = "asiyah";
              container = "romm";
              widget = {
                type = "romm";
                url = "http://127.0.0.1:${toString ports.romm}";
              };
            };
          }
          {
            "Neko" = {
              description = "A self-hosted virtual browser.";
              href = "https://neko.constellation.moe/";
              icon = "sh-neko.svg";
              server = "asiyah";
              container = "neko";
              showStats = true;
            };
          }
        ];
      }
      {
        "Media Internal" = [
          {
            "ErsatzTV" = {
              description = "Software for configuring and streaming custom live channels using your media library.";
              href = "https://ersatztv.constellation.moe/";
              icon = "sh-ersatztv.svg";
              server = "asiyah";
              container = "ersatztv";
              showStats = true;
            };
          }
          {
            "Pinchflat" = {
              description = "A self-hosted app for downloading YouTube content built using yt-dlp.";
              href = "https://pinchflat.constellation.moe/";
              icon = "sh-pinchflat.png";
              siteMonitor = "http://127.0.0.1:${toString ports.pinchflat}";
            };
          }
          {
            "Prowlarr" = {
              description = "An indexer manager/proxy supporting management of both Torrent Trackers and Usenet Indexers.";
              href = "https://prowlarr.constellation.moe/";
              icon = "sh-prowlarr.svg";
              server = "asiyah";
              container = "prowlarr";
              widget = {
                type = "prowlarr";
                url = "http://127.0.0.1:${toString ports.prowlarr}";
                key = "{{HOMEPAGE_VAR_PROWLARR_API_KEY}}";
              };
            };
          }
          {
            "Radarr" = {
              description = "A movie organizer/manager for usenet and torrent users.";
              href = "https://radarr.constellation.moe/";
              icon = "sh-radarr.svg";
              server = "asiyah";
              container = "radarr";
              widget = {
                type = "radarr";
                url = "http://127.0.0.1:${toString ports.radarr}";
                key = "{{HOMEPAGE_VAR_RADARR_API_KEY}}";
                enableQueue = true;
              };
            };
          }
          {
            "Sonarr" = {
              description = "A PVR for Usenet and BitTorrent users.";
              href = "https://sonarr.constellation.moe/";
              icon = "sh-sonarr.svg";
              server = "asiyah";
              container = "sonarr";
              widget = {
                type = "sonarr";
                url = "http://127.0.0.1:${toString ports.sonarr}";
                key = "{{HOMEPAGE_VAR_SONARR_API_KEY}}";
                enableQueue = true;
              };
            };
          }
          {
            "Bazarr" = {
              description = "A companion app that helps you find and download subtitles for your media files";
              href = "https://bazarr.constellation.moe/";
              icon = "sh-bazarr.png";
              server = "asiyah";
              container = "bazarr";
              widget = {
                type = "bazarr";
                url = "http://127.0.0.1:${toString ports.bazarr}";
                key = "{{HOMEPAGE_VAR_BAZARR_API_KEY}}";
              };
            };
          }
          {
            "Readarr" = {
              description = "Monitors RSS feeds for new books and downloads them with clients and indexers.";
              href = "https://readarr.constellation.moe/";
              icon = "sh-readarr.svg";
              server = "asiyah";
              container = "readarr";
              widget = {
                type = "readarr";
                url = "http://127.0.0.1:${toString ports.readarr}";
                key = "{{HOMEPAGE_VAR_READARR_API_KEY}}";
              };
            };
          }
          {
            "Lidarr" = {
              description = "A music collection manager for Usenet and BitTorrent users.";
              href = "https://lidarr.constellation.moe/";
              icon = "sh-lidarr.svg";
              server = "asiyah";
              container = "lidarr";
              widget = {
                type = "lidarr";
                url = "http://127.0.0.1:${toString ports.lidarr}";
                key = "{{HOMEPAGE_VAR_LIDARR_API_KEY}}";
              };
            };
          }
          {
            "Slskd" = {
              description = "Client-server client software for the Soulseek peer-to-peer file sharing network.";
              href = "https://slskd.constellation.moe/";
              icon = "sh-slskd.svg";
              server = "asiyah";
              container = "slskd";
              widget = {
                type = "slskd";
                url = "http://127.0.0.1:${toString ports.slskd}";
                key = "{{HOMEPAGE_VAR_SLSKD_API_KEY}}";
              };
            };
          }
          {
            "Calibre Downloader" = {
              description = "An intuitive web interface for searching and requesting book downloads, designed to work seamlessly with Calibre-Web-Automated.";
              href = "https://calibredl.constellation.moe/";
              icon = "sh-calibre.svg";
              server = "asiyah";
              container = "calibre";
              showStats = true;
            };
          }
          {
            "Tdarr" = {
              description = "A cross-platform conditional based transcoding application for automating media library transcode/remux management,";
              href = "https://tdarr.constellation.moe/";
              icon = "sh-tdarr.png";
              server = "asiyah";
              container = "tdarr";
              widget = {
                type = "tdarr";
                url = "http://127.0.0.1:${toString ports.tdarr-webui}";
              };
            };
          }
          {
            "qBittorrent" = {
              description = "A free and reliable P2P BitTorrent client.";
              href = "https://torrent.constellation.moe/";
              icon = "sh-qbittorrent.svg";
              server = "asiyah";
              container = "qbittorrent";
              widget = {
                type = "qbittorrent";
                url = "http://127.0.0.1:${toString ports.qbittorrent-webui}";
                username = "{{HOMEPAGE_VAR_QBITTORRENT_USERNAME}}";
                password = "{{HOMEPAGE_VAR_QBITTORRENT_PASSWORD}}";
              };
            };
          }
          {
            "Bitmagnet" = {
              description = "A software that crawls the DHT network and indexes torrents from any source, allowing you to search and classify content.";
              href = "https://bitmagnet.constellation.moe/";
              icon = "sh-bitmagnet.png";
              server = "asiyah";
              container = "bitmagnet";
              showStats = true;
            };
          }
          {
            "SABnzbd" = {
              description = "An open-source binary newsreader that automates downloading, verifying, repairing and extracting .nzb files.";
              href = "https://sabnzbd.constellation.moe/";
              icon = "sh-sabnzbd.svg";
              server = "asiyah";
              container = "sabnzbd";
              widget = {
                type = "sabnzbd";
                url = "http://127.0.0.1:${toString ports.sabnzbd}";
                key = "{{HOMEPAGE_VAR_SABNZBD_API_KEY}}";
              };
            };
          }
        ];
      }
    ];
    docker = {
      asiyah = {
        socket = "/var/run/podman/podman.sock";
      };
    };
  };

  systemd.services.homepage-dashboard = {
    serviceConfig = {
      # Needed for Docker/Podman integration
      SupplementaryGroups = "podman";
    };
  };

}