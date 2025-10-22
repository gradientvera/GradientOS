{ ... }:
{
  imports = [
    ./networking.nix
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
  networking.domain = "";
  services.openssh.enable = true;
  users.users.root.openssh.authorizedKeys.keys = [''ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOH4ZOMQX/C9x2s4D7mvP7ip1ll+Nhar+tCJiTpy1DuY'' ];
}
