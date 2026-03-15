{ config, lib, ... }:
let
  ports = config.gradient.currentHost.ports;
in
{

  services.esphome = {
    enable = true;
    usePing = true;
    address = "0.0.0.0";
    port = ports.esphome;
  };

  systemd.tmpfiles.settings."10-esphome" = 
  let
    mkDevice = file: {
      argument = toString ./${file};
      repoPath = "/etc/nixos/hosts/asiyah/esphome/${file}";
      doCheck = true;
      user = "esphome";
      group = "esphome";
      mode = "0755";
    };
  in
  {
    "/var/lib/esphome/bk7231n-ir-blaster.yaml".C = mkDevice "bk7231n-ir-blaster.yaml";
    "/var/lib/esphome/kaysun-ac-living-room.yaml".C = mkDevice "kaysun-ac-living-room.yaml";
    "/var/lib/esphome/kaysun-ac-vera-bedroom.yaml".C = mkDevice "kaysun-ac-vera-bedroom.yaml";
    "/var/lib/esphome/sonoff-rf-bridge-r2.yaml".C = mkDevice "sonoff-rf-bridge-r2.yaml";
    "/var/lib/esphome/smart-air-freshener.yaml".C = mkDevice "smart-air-freshener.yaml";
    "/var/lib/esphome/espbell-lite.yaml".C = mkDevice "espbell-lite.yaml";
    "/var/lib/esphome/gas-canister-scale.yaml".C = mkDevice "gas-canister-scale.yaml";
  };

  networking.firewall.interfaces.gradientnet.allowedTCPPorts = [ ports.esphome ];
  networking.firewall.interfaces.gradientnet.allowedUDPPorts = [ ports.esphome ];

}