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

  gradient.containers.autoUpdate = true;

  virtualisation.oci-containers.backend = "podman";

  virtualisation.containers = {
    enable = true;
    registries.search = [
      "docker.io"
      "ghcr.io"
    ];
  };

  # Allow accesing published ports...
  boot.kernel.sysctl."net.ipv4.conf.podman0.route_localnet" = 1;

  environment.etc."NetworkManager/dnsmasq.d/podman.conf".text = ''
except-interface=podman0
'';

  systemd.network.wait-online.ignoredInterfaces = ["podman0"];
  
  systemd.timers.podman-auto-update = {
    enable = true;
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = [ "" "Mon 05:00" ];
      RandomizedDelaySec = "2h";
      Persistent = true;
    };
  };

}