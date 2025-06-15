{ pkgs, ... }:

{

  services.uvcvideo.dynctrl = {
    enable = true;
    packages = [ pkgs.tiscamera ]; # Workaround until nixpkgs unstable fixes tiscamera
  };
  
}