{ pkgs, ... }:

{

  services.uvcvideo.dynctrl = {
    enable = true;
    packages = [ pkgs.stable.tiscamera ]; # Workaround until nixpkgs unstable fixes tiscamera
  };
  
}