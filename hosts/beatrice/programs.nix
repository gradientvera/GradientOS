{ pkgs, ... }:
{

  environment.systemPackages = with pkgs; [
    unstable.wlr-randr
  ];

  services.flatpak.packages = [
    # "flathub:app/com.moonlight_stream.Moonlight/x86_64/stable"
  ];

}