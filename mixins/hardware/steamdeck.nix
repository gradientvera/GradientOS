{ pkgs, ... }:

{

  imports = [
    ./steamdeck-minimal.nix
    ../jovian-decky-loader.nix
  ];

  jovian.steam.enable = true;

  # Add some useful packages.
  environment.systemPackages = with pkgs; [
    mangohud
  ];

}
