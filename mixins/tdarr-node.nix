{ config, ... }:
let
  asiyahPorts = import ../hosts/asiyah/misc/service-ports.nix;
  addresses = import ../misc/wireguard-addresses.nix;
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
      "x-systemd.automount"
      "noauto"
      "nofail"
      "noatime"
      "_netdev"
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
  };

  systemd.services.podman-tdarrNode = {
    after = [ "var-lib-tdarr.mount" "asiyahMedia.mount" ];
    bindsTo = [ "var-lib-tdarr.mount" "asiyahMedia.mount" ];
  };

}