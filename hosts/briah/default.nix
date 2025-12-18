{ ... }:
{
  imports = [
    ./nginx.nix
    ./networking.nix
    ./secrets/default.nix
    ./hardware-configuration.nix
  ];

  gradient.core.enable = true;

  boot.tmp.cleanOnBoot = true;
  zramSwap.enable = true;
  services.swapspace.enable = true;
  networking.hostName = "briah";
  networking.domain = "";
  services.openssh.enable = true;
}
