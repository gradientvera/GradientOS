final: prev: {
  home-assistant-custom-components-gradientos = {
    radarr-upcoming-media = prev.callPackage ../pkgs/hass/radarr-upcoming-media.nix { };
    sonarr-upcoming-media = prev.callPackage ../pkgs/hass/sonarr-upcoming-media.nix { };
    mqtt-vacuum-camera = prev.callPackage ../pkgs/hass/mqtt-vacuum-camera.nix { };
    thermal-comfort = prev.callPackage ../pkgs/hass/thermal-comfort.nix { };
    anniversaries = prev.callPackage ../pkgs/hass/anniversaries.nix { };
    hass-ingress = prev.callPackage ../pkgs/hass/hass-ingress.nix { };
    # openrgb-ha = prev.callPackage ../pkgs/hass/openrgb-ha.nix { };
    feedparser = prev.callPackage ../pkgs/hass/feedparser.nix { };
    bermuda = prev.callPackage ../pkgs/hass/bermuda.nix { };
    edata = prev.callPackage ../pkgs/hass/edata.nix { };
  };
  home-assistant-custom-lovelace-modules-gradientos = {
    xiaomi-vacuum-map-card = prev.callPackage ../pkgs/hass/xiaomi-vacuum-map-card.nix { };
  };
}