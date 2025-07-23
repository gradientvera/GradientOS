{ pkgs, ... }:

{

  home.packages = with pkgs; [
    stable.gimp-with-plugins
    kdePackages.kolourpaint
    lxqt.pavucontrol-qt
    kdePackages.okular
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
    vlc
    mpv
  ];

}