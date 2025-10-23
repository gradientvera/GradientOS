{ ... }:
{
  imports = [
    ./secrets/default.nix
    ./hardware-configuration.nix
  ];

  gradient.core.enable = true;

  boot.kernel.sysctl = {
    # Increase max amount of connections
    "net.core.somaxconn" = "8192";
  };

  boot.tmp.cleanOnBoot = true;
  zramSwap.enable = true;
  networking.hostName = "briah";
  networking.domain = "vps.ovh.net";
  services.openssh.enable = true;
}
