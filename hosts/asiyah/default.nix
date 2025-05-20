{ config, pkgs, ... }:
{

  imports = [
    ./nfs.nix
    ./mqtt.nix
    ./fail2ban
    ./searx.nix
    ./redis.nix
    ./trmnl.nix
    ./numad.nix
    ./radio.nix
    ./zigbee.nix
    ./clamav.nix
    ./kanidm.nix
    ./backups.nix
    ./grafana.nix
    ./forgejo.nix
    ./duckdns.nix
    ./postgres.nix
    ./scrutiny.nix
    ./paperless.nix
    ./cloudflare.nix
    ./filesystem.nix
    ./vaultwarden.nix
    ./media-stack.nix
    ./nginx/default.nix
    ./home-assistant.nix
    ./esphome/default.nix
    ./victoriametrics.nix
    ./palworld-server.nix
    ./secrets/default.nix
    ./libvirtd/default.nix
    ./redbot-stardream.nix
    ./gradient-generator.nix
    # ./project-zomboid-server.nix
    ./hardware-configuration.nix
    ./trilium-memory-repository.nix
  ];

  networking.hostId = "b4ed7361";

  gradient.presets.syncthing.enable = true;
  gradient.profiles.catppuccin.enable = true;
  gradient.profiles.graphics.enable = true;

  gradient.kernel.hugepages.enable = true;

  boot.kernel.sysctl = {
    # Increase max amount of connections
    "net.core.somaxconn" = "8192";
  };

  environment.systemPackages = with pkgs; [
    numactl
    numatop
    jdupes
    numad
  ];

  gradient.substituters = {
    briah = "ssh-ng://nix-ssh@briah.gradient?priority=60";
    bernkastel = "ssh-ng://nix-ssh@bernkastel.gradient?priority=40";
    beatrice = "ssh-ng://nix-ssh@beatrice.gradient?priority=45";
    erika = "ssh-ng://nix-ssh@erika.gradient?priority=50";
    neith-deck = "ssh-ng://nix-ssh@neith-deck.lily?priority=100";
  };
  
}