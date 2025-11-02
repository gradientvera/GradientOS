{ pkgs, ... }:

{

  services.uvcvideo.dynctrl = {
    # enable = true; # TODO: Borked!
    packages = [ pkgs.tiscamera ]; # Workaround until nixpkgs unstable fixes tiscamera
  };
  
}