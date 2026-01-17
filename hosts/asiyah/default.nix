{ config, pkgs, ... }:
{

  imports = [
    ./nfs.nix
    ./mqtt.nix
    ./wolf.nix
    ./searx.nix
    ./redis.nix
    ./alloy.nix
    ./numad.nix
    ./radio.nix
    ./attic.nix
    ./crafty.nix
    ./zigbee.nix
    ./clamav.nix
    ./kanidm.nix
    ./hytale.nix
    ./backups.nix
    ./frigate.nix
    ./grafana.nix
    ./forgejo.nix
    ./duckdns.nix
    ./olivetin.nix
    ./postgres.nix
    ./scrutiny.nix
    ./paperless.nix
    ./cloudflare.nix
    ./filesystem.nix
    ./vaultwarden.nix
    ./media-stack.nix
    ./uptime-kuma.nix
    ./victorialogs.nix
    ./nginx/default.nix
    ./home-assistant.nix
    ./esphome/default.nix
    ./victoriametrics.nix
    ./palworld-server.nix
    ./secrets/default.nix
    #./libvirtd/default.nix # Unused, removed SSD for now
    ./redbot-stardream.nix
    ./large-lying-models.nix
    ./gradient-generator.nix
    # ./project-zomboid-server.nix
    ./hardware-configuration.nix
    ./trilium-memory-repository.nix
  ];

  networking.hostId = "b4ed7361";

  gradient.presets.syncthing.enable = true;
  gradient.profiles.catppuccin.enable = true;
  gradient.profiles.graphics.enable = true;

  gradient.kernel.transparent_hugepages.enable = true;

  virtualisation.podman.dockerSocket.enable = true;

  environment.systemPackages = with pkgs; [
    numactl
    numatop
    jdupes
    numad
  ];

  gradient.substituters = {
    bernkastel = "ssh-ng://nix-ssh@bernkastel.gradient?priority=40";
    erika = "ssh-ng://nix-ssh@erika.gradient?priority=50";
  };
  
}