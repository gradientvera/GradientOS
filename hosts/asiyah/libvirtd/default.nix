{ ... }:
{

  imports = [
    ./ange.nix
  ];

  virtualisation.libvirtd = {
    enable = true;
    onBoot = "ignore";
    onShutdown = "suspend";
    qemu = {
      runAsRoot = true;
      ovmf.enable = true;
    };
  };

}