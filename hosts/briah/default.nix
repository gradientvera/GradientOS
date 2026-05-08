{ ... }:
{
  imports = [
    ./nginx.nix
    ./headscale.nix
    ./networking.nix
    ./filesystems.nix
    ./secrets/default.nix
    ./hardware-configuration.nix
  ];

  gradient.core.enable = true;

  boot.tmp.cleanOnBoot = true;
  services.swapspace.enable = true;
  networking.hostName = "briah";
  networking.domain = "";
  services.openssh.enable = true;
}
