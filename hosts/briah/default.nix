{ ... }:
{
  imports = [
    ./haproxy.nix
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
  services.swapspace.enable = true;
  networking.hostName = "briah";
  networking.domain = "";
  services.openssh.enable = true;
}
