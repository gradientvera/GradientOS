{ pkgs, ... }:

{

  home.packages = with pkgs; [
    kdePackages.kolourpaint
    lxqt.pavucontrol-qt
    kdePackages.okular
    gimp-with-plugins
    kdePackages.kate
    telegram-desktop
    discord-canary
    google-chrome
    moonlight-qt
    qbittorrent
    chromium
    qpwgraph
    firefox
    discord
    spotify
    vlc
    mpv
  ];

}