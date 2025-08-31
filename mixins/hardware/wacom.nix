{ pkgs, ... }:

{

  services.xserver.wacom.enable = true;

  environment.systemPackages = with pkgs; [
    kdePackages.wacomtablet
    libwacom
  ];

}