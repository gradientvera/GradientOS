{ lib, ... }:
{

  networking = {
    networkmanager.enable = lib.mkForce false;

    nameservers = [ "1.1.1.1" "1.0.0.1" "8.8.8.8" "8.8.4.4" ];

    defaultGateway = "172.31.1.1";

    defaultGateway6 = {
      address = "fe80::1";
      interface = "eth0";
    };

    dhcpcd.enable = false;

    usePredictableInterfaceNames = lib.mkForce false;

    interfaces.eth0 = {
      ipv4.addresses = [
        { address="5.75.186.155"; prefixLength=32; }
      ];
      ipv4.routes = [ { address = "172.31.1.1"; prefixLength = 32; } ];
      
      ipv6.addresses = [
        { address="2a01:4f8:c2c:9da3::1"; prefixLength=64; }
        { address="fe80::9000:6ff:fea2:8b08"; prefixLength=64; }
      ];
      ipv6.routes = [ { address = "fe80::1"; prefixLength = 128; } ];
    };

  };

  services.udev.extraRules = ''
    ATTR{address}=="92:00:06:a2:8b:08", NAME="eth0"
  '';
}
