{ pkgs, ... }:

{

  virtualisation.spiceUSBRedirection.enable = true;
  virtualisation.libvirtd.enable = true;
  programs.virt-manager.enable = true;

}