{ config, ... }:
let ports = config.gradient.currentHost.ports; in
{

  systemd.tmpfiles.settings."10-libvirtd" = {
    
    "/var/lib/libvirt/qemu/ange.xml".C = {
      argument = "${./ange.xml}";
      repoPath = "/etc/nixos/hosts/asiyah/libvirtd/ange.xml";
      doCheck = true;
      group = "libvirtd";
      mode = "0666";
    };

  };


  networking.firewall.interfaces.gradientnet.allowedTCPPorts = [ ports.ange-spice ];
  networking.firewall.interfaces.gradientnet.allowedUDPPorts = [ ports.ange-spice ];

}