{ pkgs, ... }:
{

  environment.systemPackages = with pkgs; [
    wl-clipboard
  ];

  services.flatpak.packages = [
    # "flathub:app/com.moonlight_stream.Moonlight/x86_64/stable"
  ];

}