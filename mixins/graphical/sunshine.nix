{ pkgs, ... }:
{

  environment.systemPackages = with pkgs; [
    sunshine
  ];

  # Sunshine ports
  networking.firewall.allowedTCPPorts = [ 47989 ];
  networking.firewall.allowedUDPPorts = [ 47989 ];

}