{ ... }:
{

  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
    autoPrune.enable = true;
    autoPrune.flags = [
      "--all"
    ];
    defaultNetwork.settings.dns_enabled = true;
  };

  virtualisation.oci-containers.backend = "podman";

  # Allow accesing published ports...
  boot.kernel.sysctl."net.ipv4.conf.podman0.route_localnet" = 1;
  
  systemd.timers.podman-auto-update = {
    enable = true;
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = [ "" "*-*-* 5:00:00" ];
      Persistent = true;
    };
  };

}