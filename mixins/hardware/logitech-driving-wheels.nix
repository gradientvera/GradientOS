{ pkgs, ... }:
{

  # Better support
  hardware.new-lg4ff.enable = true;

  # Steering wheel manager
  environment.systemPackages = [
    pkgs.oversteer
  ];

}