{ pkgs, ... }:

{

  imports = [
    ./konsole/default.nix
  ];

  home.packages = with pkgs; [
    master.discord-canary
    lxqt.pavucontrol-qt
    kdePackages.okular
    bitwarden-desktop
    gimp-with-plugins
    libreoffice-fresh
    telegram-desktop
    kdePackages.kate
    element-desktop
    master.tenacity # unstable was broken
    master.discord
    qbittorrent
    glabels-qt
    chromium
    inkscape
    firefox
    vesktop
    krita
    vmpk
    peek
    vlc
    mpv
  ];

}