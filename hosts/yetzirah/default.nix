{ ... }:
{
 
  imports = [
    ./klipper.nix
    ./mainsail.nix
    ./moonraker.nix
    ./ustreamer.nix
    ./filesystem.nix
    ./kiosk-session.nix
    ./secrets/default.nix
    ./hardware-configuration.nix
  ];  

  gradient.profiles.catppuccin.enable = true;
  gradient.profiles.graphics.enable = true;
  gradient.kernel.hugepages.enable = true;

}