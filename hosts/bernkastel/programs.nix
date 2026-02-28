{ pkgs, ... }:
{

  environment.systemPackages = with pkgs; [
    gradient-generator
    losslesscut-bin
    stable.openscad
    prusa-slicer
    orca-slicer
    # freecad # TODO: borked
  ];

}