{ pkgs, ... }:

{

  hardware.opentabletdriver.enable = true;
  hardware.opentabletdriver.daemon.enable = true;

  environment.systemPackages = with pkgs; [
    kdePackages.wacomtablet
  ];

}
