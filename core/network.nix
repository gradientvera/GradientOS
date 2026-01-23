{ lib, ... }:

{
  networking.interfaces.lo.ipv6.addresses = [
    {
      address = "::2";
      prefixLength = 128;
    }
  ];

  # Enable NetworkManager with dnsmasq
  networking.networkmanager = {
    enable = lib.mkDefault true;
    dns = "dnsmasq";
    wifi.backend = "iwd";
  };

  environment.etc."NetworkManager/dnsmasq.d/nameservers.conf".text = ''
local=/local/
domain=local
expand-hosts
server=1.1.1.1
server=1.0.0.1
server=8.8.8.8
server=8.8.4.4
server=2606:4700:4700::1111
server=2606:4700:4700::1001
  '';

  # Ignore loopback/virtual interfaces.
  systemd.network.wait-online.ignoredInterfaces = ["lo" "virbr0"];
}