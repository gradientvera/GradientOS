{ modulesPath, ... }:
{
  imports = [ (modulesPath + "/profiles/qemu-guest.nix") ];
  
  hardware.facter.reportPath = ./facter.json;
  boot.initrd.availableKernelModules = [ "ata_piix" "uhci_hcd" "xen_blkfront" "vmw_pvscsi" ];
  boot.initrd.kernelModules = [ "nvme" ];
  
}