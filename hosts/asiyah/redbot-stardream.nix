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
    extraOptions = [
      "--ip" "10.88.0.3"
    ];
    labels = {
      "io.containers.autoupdate" = "registry";
      "PODMAN_SYSTEMD_UNIT" = "podman-stardream.service";
    };
  };

}