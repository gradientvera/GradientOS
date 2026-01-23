{ pkgs, ... }:
{

  environment.systemPackages = with pkgs; [
    gradient-generator
    losslesscut-bin
    prusa-slicer
    orca-slicer
    openscad
    # freecad # TODO: borked
  ];

}