{ config, ... }:
{

  virtualisation.oci-containers.containers.stardream = {
    image = "ghcr.io/phasecorex/red-discordbot:extra-audio";
    pull = "newer";
    volumes = [ "/data/stardream:/data" ];
    environment = {
      TZ = config.time.timeZone;
      OWNER = "132502019981180928";
      EXTRA_ARGS = "--dev";
    };
  };

  systemd.services.podman-stardream = {
    wants = [ "network-online.target" ];
    after = [ "network-online.target" ];
  };

}