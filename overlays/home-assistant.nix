final: prev: {
  home-assistant-custom-components-gradientos = {
    radarr-upcoming-media = prev.callPackage ../pkgs/hass/radarr-upcoming-media.nix { };
    sonarr-upcoming-media = prev.callPackage ../pkgs/hass/sonarr-upcoming-media.nix { };
    thermal-comfort = prev.callPackage ../pkgs/hass/thermal-comfort.nix { };
    anniversaries = prev.callPackage ../pkgs/hass/anniversaries.nix { };
    openrgb-ha = prev.callPackage ../pkgs/hass/openrgb-ha.nix { };
    feedparser = prev.callPackage ../pkgs/hass/feedparser.nix { };
    bermuda = prev.callPackage ../pkgs/hass/bermuda.nix { };
    edata = prev.callPackage ../pkgs/hass/edata.nix { };
  };
}