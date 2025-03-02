{ pkgs, ... }:

{

  imports = [
    ./steamdeck-minimal.nix
  ];

  jovian.steam.enable = true;

  # Requires enabling CEF remote debugging on the Developer menu settings to work.
  jovian.decky-loader.enable = true;

  # Add some useful packages.
  environment.systemPackages = with pkgs; [
    mangohud
  ];

}
