{ modulesPath, lib, ... }:
{

  imports = [
    "${modulesPath}/virtualisation/azure-common.nix"
    ../mixins/networkd.nix
  ];

  # Forcibly disable NetworkManager.
  networking.networkmanager.enable = lib.mkForce false;

}