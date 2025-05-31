{ pkgs, ... }:

{

  home.packages = with pkgs; [
    kdePackages.kolourpaint
    lxqt.pavucontrol-qt
    kdePackages.okular
    gimp-with-plugins
    kdePackages.kate
    discord-canary
    google-chrome
    moonlight-qt
    qbittorrent
    chromium
    tdesktop
    qpwgraph
    firefox
    discord
    spotify
    carla
    vlc
    mpv
  ];

}