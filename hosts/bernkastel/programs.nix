{ pkgs, ... }:
{

  environment.systemPackages = with pkgs; [
    gradient-generator
    losslesscut-bin
    stable.freecad
    prusa-slicer
    openscad
  ];

  services.flatpak.packages = [
    # "flathub:app/com.moonlight_stream.Moonlight/x86_64/stable"
  ];
  
}