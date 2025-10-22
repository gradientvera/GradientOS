{ pkgs, ... }:
let
  win10-hooks = pkgs.writeShellApplication {
    name = "win10-hooks";
    runtimeInputs = with pkgs; [ libvirt kmod gawk lsof ];
    text = builtins.readFile ./win10-hooks.sh;
    checkPhase = "";
  };
in {
  
  virtualisation.libvirtd = {
    enable = true;
    onBoot = "ignore";
    onShutdown = "shutdown";
    qemu = {
      runAsRoot = true;
    };
    hooks.qemu = {
      "win10-hooks.sh" = "${win10-hooks}/bin/win10-hooks";
    };
  };

  boot.extraModprobeConfig = ''
    options vfio-pci ids=1002:73bf,1002:ab28,1002:73a6,1002:73a4
  '';

  systemd.tmpfiles.settings."10-libvirtd" = {
    
    "/var/lib/libvirt/vbios.rom".C = {
      argument = "${./vbios.rom}";
      repoPath = "/etc/nixos/hosts/bernkastel/libvirtd/vbios.rom";
      doCheck = true;
      group = "libvirtd";
      mode = "0664";
    };

    "/var/lib/libvirt/qemu/win10.xml".C = {
      argument = "${./win10.xml}";
      repoPath = "/etc/nixos/hosts/bernkastel/libvirtd/win10.xml";
      doCheck = true;
      group = "libvirtd";
      mode = "0666";
    };

    "/var/lib/libvirt/qemu/win10-no-passthrough.xml".C = {
      argument = "${./win10-no-passthrough.xml}";
      repoPath = "/etc/nixos/hosts/bernkastel/libvirtd/win10-no-passthrough.xml";
      doCheck = true;
      group = "libvirtd";
      mode = "0666";
    };

  };
}