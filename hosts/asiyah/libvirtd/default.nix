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
      package = pkgs.qemu;
      runAsRoot = true;
      swtpm.enable = true;
      vhostUserPackages = [
        pkgs.virtiofsd
      ];
    };
  };

  boot.kernelModules = [ "qxl" ];

}