{ config, pkgs, lib, ... }:
{

  hardware.rtl-sdr.enable = true;

  virtualisation.oci-containers.containers.openwebrxplus = {
    image = "slechev/openwebrxplus-softmbe:latest";
    pull = "newer";
    ports = [ "127.0.0.1:${toString config.gradient.currentHost.ports.openwebrx}:8073" ];
    volumes = [
      "/var/lib/openwebrx:/var/lib/openwebrx"
      "/var/lib/openwebrx/etc:/etc/openwebrx"
      "/var/lib/openwebrx/plugins:/usr/lib/python3/dist-packages/htdocs/plugins"
    ];
    environment = {
      TZ = config.time.timeZone;
      OPENWEBRX_ADMIN_USER = "admin";
      OPENWEBRX_ADMIN_PASSWORD = "password";
    };
    extraOptions = [
      "--ip" "10.88.0.8"
      "--device" "/dev/bus/usb"
    ];
  };

  /*systemd.services.openwebrx.serviceConfig = {
    DynamicUser = lib.mkForce false;
    User = config.users.users.openwebrx.name;
    Group = config.users.users.openwebrx.group;
  };

  users.users.openwebrx = {
    isSystemUser = true;
    home = "/var/lib/openwebrx";
    createHome = true;
    homeMode = "750";
    group = config.users.groups.openwebrx.name;
    # Allow access to RTL-SDR
    extraGroups = [ config.users.groups.plugdev.name ];
  };

  users.groups.openwebrx = {};*/

}