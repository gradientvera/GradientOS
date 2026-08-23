{ pkgs, ... }:

{

  imports = [
    ./konsole/default.nix
  ];

  home.packages = with pkgs; [
    lxqt.pavucontrol-qt
    kdePackages.okular
    bitwarden-desktop
    gimp-with-plugins
    libreoffice-fresh
    telegram-desktop
    kdePackages.kate
    element-desktop
    discord-canary
    qbittorrent
    glabels-qt
    chromium
    inkscape
    tenacity
    discord
    firefox
    vesktop
    krita
    vmpk
    peek
    vlc
    mpv
  ];

}
