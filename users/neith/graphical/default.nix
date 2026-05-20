{ pkgs, ... }:

{

  home.packages = with pkgs; [
    kdePackages.kolourpaint
    master.discord-canary
    lxqt.pavucontrol-qt
    kdePackages.okular
    gimp-with-plugins
    kdePackages.kate
    telegram-desktop
    master.discord
    google-chrome
    moonlight-qt
    qbittorrent
    chromium
    qpwgraph
    firefox
    spotify
    anki
    vlc
    mpv
  ];

}