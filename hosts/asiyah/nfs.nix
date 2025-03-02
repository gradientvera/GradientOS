{ config, ... }:
let
  ports = import ./misc/service-ports.nix;
  addresses = import ../../misc/wireguard-addresses.nix;
in
{

  services.rpcbind.enable = true;
  services.nfs.server = {
    enable = true;
    statdPort = ports.statd;
    lockdPort = ports.lockd;
    mountdPort = ports.mountd;
    createMountPoints = true;
    exports = let
      mediarrConfig = "${addresses.gradientnet.gradientnet}/24(rw,all_squash,anonuid=${toString config.users.users.mediarr.uid},anongid=${toString config.users.groups.mediarr.gid})";
    in
    ''
      /export/downloads ${mediarrConfig}
      /export/mediarr ${mediarrConfig}
    '';
  };
  services.nfs.settings = {
    nfsd.udp = false;
    nfsd.vers3 = false;
    nfsd.vers4 = true;
    nfsd."vers4.0" = false;
    nfsd."vers4.1" = false;
    nfsd."vers4.2" = true;
  };

  fileSystems."/export/downloads" = {
    device = "/data/downloads";
    options = [ "bind" ];
  };

  fileSystems."/export/mediarr" = {
    device = "/var/lib/mediarr";
    options = [ "bind" ];
  };

  networking.firewall.interfaces.gradientnet = {
    allowedTCPPorts = [
      ports.nfsd
      ports.statd
      ports.lockd
      ports.mountd
    ];
    allowedUDPPorts = [
      ports.nfsd
      ports.statd
      ports.lockd
      ports.mountd
    ];
  };

}