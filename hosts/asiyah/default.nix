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
    ./backups.nix
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
    ./libvirtd/default.nix
    ./redbot-stardream.nix
    # ./large-lying-models.nix # Borked
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
    beatrice = "ssh-ng://nix-ssh@beatrice.gradient?priority=45";
    erika = "ssh-ng://nix-ssh@erika.gradient?priority=50";
    neith-deck = "ssh-ng://nix-ssh@neith-deck.lily?priority=100";
  };
  
}