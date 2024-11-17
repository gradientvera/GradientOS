{ pkgs, ... }:
{

  services.tor = {
    enable = true;
    client.enable = true;
    client.dns.enable = true;
    torsocks.enable = true;
  };

  systemd.services.tor.after = [ "network-online.target" ];
  systemd.services.tor.wants = [ "network-online.target" ];

  environment.systemPackages = with pkgs; [
    tor-browser
  ];

}