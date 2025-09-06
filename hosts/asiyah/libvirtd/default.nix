{ pkgs, ... }:
{

  imports = [
    ./ange.nix
  ];

  virtualisation.libvirtd = {
    enable = true;
    onBoot = "ignore";
    onShutdown = "suspend";
    qemu = {
      package = pkgs.qemu_full;
      runAsRoot = true;
      ovmf.enable = true;
      swtpm.enable = true;
      vhostUserPackages = [
        pkgs.virtiofsd
      ];
    };
  };

  boot.kernelModules = [ "qxl" ];

}