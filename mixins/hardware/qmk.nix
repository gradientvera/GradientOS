{ pkgs, ... }:
{

  hardware.keyboard.qmk.enable = true;

  environment.systemPackages = [
    pkgs.qmk_hid
    pkgs.vial
    pkgs.qmk
  ];

}