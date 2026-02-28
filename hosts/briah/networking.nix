{ lib, ... }: {
  # This file was populated at runtime with the networking
  # details gathered from the active system.
  networking = {
    nameservers = [
      "2606:4700:4700::1111"
      "2606:4700:4700::1001"
      "1.1.1.1"
      "1.0.0.1"
    ];
    defaultGateway = "172.31.1.1";
    defaultGateway6 = {
      address = "fe80::1";
      interface = "eth0";
    };
    dhcpcd.enable = false;
    usePredictableInterfaceNames = lib.mkForce false;
    interfaces = {
      eth0 = {
        ipv4.addresses = [
          { address="91.98.226.45"; prefixLength=32; }
        ];
        ipv6.addresses = [
          { address="2a01:4f8:1c1a:5e97::1"; prefixLength=64; }
          { address="fe80::9000:6ff:feb3:e1f0"; prefixLength=64; }
        ];
        ipv4.routes = [ { address = "172.31.1.1"; prefixLength = 32; } ];
        ipv6.routes = [ { address = "fe80::1"; prefixLength = 128; } ];
      };
    };
  };
  services.udev.extraRules = ''
    ATTR{address}=="92:00:06:b3:e1:f0", NAME="eth0"
    
  '';
  networking.networkmanager.enable = lib.mkForce false;
  networking.resolvconf.enable = lib.mkForce false;
}