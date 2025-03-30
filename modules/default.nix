# Dummy module that imports every other module here.
# Some of these require the "core" module.
{ ... }:
{

  imports = [
    ./kernel
    ./presets
    ./hardware
    ./profiles
    ./nginx-robots.nix
    ./tmpfiles-check.nix
    ./substituter-switcher.nix
  ];

}