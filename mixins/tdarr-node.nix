{ config, ... }:
let
  asiyahPorts = config.gradient.hosts.asiyah.ports;
  addresses = config.gradient.const.wireguard.addresses;
  userUid = 976;
  groupGid = 972;
in
{

  imports = [
    ./podman.nix
  ]; 

  users.users.tdarr = {
    isSystemUser = true;
    linger = true;
    home = "/var/lib/tdarr";
    createHome = true;
    uid = userUid;
    homeMode = "775";
    group = "tdarr";
    extraGroups = [ "render" ];
  };

  users.groups.tdarr = {
    gid = groupGid;
  };
  
  boot.kernelModules = [ "nfs" ];

  fileSystems =
  let
    nfsOptions = [
      "nfsvers=4.2"
      "_netdev"
      "noauto"
      "x-systemd.automount"
      "x-systemd.mount-timeout=10"
      "x-systemd.idle-timeout=1min"
      "timeo=14"
      "nofail"
      "noatime"
    ];
  in
  {
    "/var/lib/tdarr" = {
      device = "${addresses.gradientnet.asiyah}:/export/mediarr/tdarr/";
      fsType = "nfs";
      options = nfsOptions;
    };

    "/asiyahMedia" = {
      device = "${addresses.gradientnet.asiyah}:/export/downloads/";
      fsType = "nfs";
      options = nfsOptions;
    };
  };

  virtualisation.oci-containers.containers.tdarrNode = {
    image = "ghcr.io/haveagitgat/tdarr_node:latest";
    pull = "newer";
    volumes = [
      "/var/lib/tdarr/server:/app/server"
      "/var/lib/tdarr/config:/app/configs"
      "/var/lib/tdarr/logs:/app/logs"
      "/var/lib/tdarr/temp:/temp"
      "/asiyahMedia/tv:/media/tv"
      "/asiyahMedia/movies:/media/movies"
      "/asiyahMedia/adverts:/media/adverts"
    ];
    environment = {
      TZ = config.time.timeZone;
      PUID = toString userUid;
      PGID = toString groupGid;
      serverIP = addresses.gradientnet.asiyah;
      serverPort = toString asiyahPorts.tdarr-server;
      ffmpegVersion = "6";
      nodeName = config.networking.hostName;
    };
    extraOptions = [
      "--network=host"
      "--device=/dev/dri/:/dev/dri/"
    ];
    labels = { "io.containers.autoupdate" = "registry"; };
  };

  systemd.services.podman-tdarrNode = {
    after = [ "var-lib-tdarr.mount" "asiyahMedia.mount" ];
    bindsTo = [ "var-lib-tdarr.mount" "asiyahMedia.mount" ];
  };

}