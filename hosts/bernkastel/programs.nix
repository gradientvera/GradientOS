{ pkgs, ... }:
{

  environment.systemPackages = with pkgs; [
    gradient-generator
    losslesscut-bin
    prusa-slicer
    orca-slicer
    openscad
    freecad
  ];

  services.flatpak.packages = [
    # "flathub:app/com.moonlight_stream.Moonlight/x86_64/stable"
  ];
  
}