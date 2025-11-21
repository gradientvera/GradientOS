# Dummy module that imports every other module here.
# Some of these require the "core" module.
{ ... }:
{

  imports = [
    ./kernel/default.nix
    ./presets/default.nix
    ./hardware/default.nix
    ./profiles/default.nix

    ./nginx-extras.nix
    ./tmpfiles-check.nix
    ./substituter-switcher.nix
  ];

}