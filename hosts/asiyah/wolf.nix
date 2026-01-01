{ config, ports, pkgs, ... }:
let
  addresses = config.gradient.const.wireguard.addresses;
in
{

  systemd.tmpfiles.settings."99-wolf.conf" = {
    "/var/lib/wolf".d = {
      mode = "0775";
    };
    "/var/run/wolf".d = {
      mode = "0775";
    };
  };

  virtualisation.oci-containers.containers.wolf = {
    image = "ghcr.io/games-on-whales/wolf:stable";
    pull = "newer";
    ports = [
      "${addresses.gradientnet.asiyah}:${toString ports.wolf-http}:${toString ports.wolf-http}/tcp"
      "${addresses.gradientnet.asiyah}:${toString ports.wolf-https}:${toString ports.wolf-https}/tcp"
      "${addresses.gradientnet.asiyah}:${toString ports.wolf-control}:${toString ports.wolf-control}/udp"
      "${addresses.gradientnet.asiyah}:${toString ports.wolf-rtsp}:${toString ports.wolf-rtsp}/tcp"
      "${addresses.gradientnet.asiyah}:${toString ports.wolf-video-ping}:${toString ports.wolf-video-ping}/udp"
      "${addresses.gradientnet.asiyah}:${toString ports.wolf-audio-ping}:${toString ports.wolf-audio-ping}/udp"

      "${addresses.lilynet.asiyah}:${toString ports.wolf-http}:${toString ports.wolf-http}/tcp"
      "${addresses.lilynet.asiyah}:${toString ports.wolf-https}:${toString ports.wolf-https}/tcp"
      "${addresses.lilynet.asiyah}:${toString ports.wolf-control}:${toString ports.wolf-control}/udp"
      "${addresses.lilynet.asiyah}:${toString ports.wolf-rtsp}:${toString ports.wolf-rtsp}/tcp"
      "${addresses.lilynet.asiyah}:${toString ports.wolf-video-ping}:${toString ports.wolf-video-ping}/udp"
      "${addresses.lilynet.asiyah}:${toString ports.wolf-audio-ping}:${toString ports.wolf-audio-ping}/udp"
    ];
    volumes = [
      "/dev/:/dev/:rw"
      "/run/udev:/run/udev:rw"
      "/var/lib/wolf:/etc/wolf:z"
      "/data/downloads/games:/games:ro"
      "/var/run/wolf:/run/user/wolf:rw"
      "/var/run/podman/podman.sock:/var/run/docker.sock:ro"
    ];
    devices = [
      "/dev/dri"
      "/dev/uinput"
      "/dev/uhid"
    ];
    environment = {
      TZ = config.time.timeZone;
      LIBVA_DRIVER_NAME = "iHD";
      GST_VAAPI_DRM_DEVICE = "/dev/dri/renderD128";
      WOLF_RENDER_NODE = "/dev/dri/renderD128";
      WOLF_STOP_CONTAINER_ON_EXIT = "TRUE";
      WOLF_HTTP_PORT = toString ports.wolf-http;
      WOLF_HTTPS_PORT = toString ports.wolf-https;
      WOLF_CONTROL_PORT = toString ports.wolf-control;
      WOLF_RTSP_SETUP_PORT = toString ports.wolf-rtsp;
      WOLF_VIDEO_PING_PORT = toString ports.wolf-video-ping;
      WOLF_AUDIO_PING_PORT = toString ports.wolf-audio-ping;
    };
    extraOptions = [
      "--ipc=host"
      "--security-opt" "label=disable"
      "--device-cgroup-rule" "c 13:* rmw"
      "--ip" "10.88.0.12"
    ];
    labels = {
      "io.containers.autoupdate" = "registry";
      "PODMAN_SYSTEMD_UNIT" = "podman-wolf.service";
    };
  };
  
  # As per https://games-on-whales.github.io/wolf/stable/user/quickstart.html#_virtual_devices_support
  services.udev.extraRules = ''
    # Allows Wolf to acces /dev/uinput (only needed for joypad support)
    KERNEL=="uinput", SUBSYSTEM=="misc", MODE="0660", GROUP="input", OPTIONS+="static_node=uinput", TAG+="uaccess"

    # Allows Wolf to access /dev/uhid (only needed for DualSense emulation)
    KERNEL=="uhid", GROUP="input", MODE="0660", TAG+="uaccess"

    # Joypads
    KERNEL=="hidraw*", ATTRS{name}=="Wolf PS5 (virtual) pad", GROUP="input", MODE="0660", ENV{ID_SEAT}="seat9"
    SUBSYSTEMS=="input", ATTRS{name}=="Wolf X-Box One (virtual) pad", MODE="0660", ENV{ID_SEAT}="seat9"
    SUBSYSTEMS=="input", ATTRS{name}=="Wolf PS5 (virtual) pad", MODE="0660", ENV{ID_SEAT}="seat9"
    SUBSYSTEMS=="input", ATTRS{name}=="Wolf gamepad (virtual) motion sensors", MODE="0660", ENV{ID_SEAT}="seat9"
    SUBSYSTEMS=="input", ATTRS{name}=="Wolf Nintendo (virtual) pad", MODE="0660", ENV{ID_SEAT}="seat9"
  '';

  systemd.services.podman-wolf = {
    after = [ "podman.socket" ];
    requires = [ "podman.socket" ];
    # Remove dangling Wolf containers which might make it crash
    preStart = ''
      ${pkgs.podman}/bin/podman ps --external --all --format '{{.ID}} {{.Names}}' \
        | ${pkgs.gawk}/bin/awk 'BEGIN{IGNORECASE=1} $2 ~ /^wolf/ {print $1}' \
        | ${pkgs.findutils}/bin/xargs -r ${pkgs.podman}/bin/podman rm --force
    '';
  };

  networking.firewall.interfaces.gradientnet = {
    allowedTCPPorts = [ ports.wolf-http ports.wolf-https ports.wolf-rtsp ];
    allowedUDPPorts = [ ports.wolf-control ports.wolf-video-ping ports.wolf-audio-ping ];
  };

  networking.firewall.interfaces.lilynet = {
    allowedTCPPorts = [ ports.wolf-http ports.wolf-https ports.wolf-rtsp ];
    allowedUDPPorts = [ ports.wolf-control ports.wolf-video-ping ports.wolf-audio-ping ];
  };

}