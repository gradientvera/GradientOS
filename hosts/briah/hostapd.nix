{ config, ... }:
{

  # Needed for hostapd to work
  networking.networkmanager.unmanaged = [ "wlan0" ];

  services.hostapd = {
    enable = true;
    radios.wlan0 = {
      channel = 8;
      wifi4.capabilities = [
        "HT40"
        "HT40-"
        "SHORT-GI-20"
        # Not supported: SHORT-GI-40
      ];
      networks.wlan0 = {
        ssid = "Maya";
        authentication.mode = "wpa3-sae";
        authentication.saePasswordsFile = config.sops.secrets.hostapd-password.path;
        settings = {
          nas_identifier = "briah.gradient";
          mobility_domain = "e621"; # hehe funny
          pmk_r1_push = 1;
        };
      };
    };
  };

}