{ pkgs, ... }:

{

  services.uvcvideo.dynctrl = {
    # enable = true;
    packages = [ pkgs.tiscamera ];
  };
  
}