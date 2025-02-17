{ config, pkgs, ... }:
{

  imports = [
    ./nfs.nix
    ./mqtt.nix
    ./searx.nix
    ./numad.nix
    ./clamav.nix
    ./backups.nix
    ./grafana.nix
    ./duckdns.nix
    ./postgres.nix
    ./cloudflare.nix
    ./scrutiny.nix
    ./filesystem.nix
    ./media-stack.nix
    ./nginx/default.nix
    ./home-assistant.nix
    ./victoriametrics.nix
    ./palworld-server.nix
    ./secrets/default.nix
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