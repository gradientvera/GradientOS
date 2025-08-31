{ pkgs, ... }:

{

  imports = [
    ./konsole/default.nix
  ];

  home.packages = with pkgs; [
    stable.gimp-with-plugins
    master.discord-canary
    lxqt.pavucontrol-qt
    whatsapp-for-linux
    kdePackages.okular
    libreoffice-fresh
    element-desktop
    kdePackages.kate
    # google-chrome # TODO: Broken build?? how??
    qbittorrent
    glabels-qt
    bitwarden
    tdesktop
    tenacity
    chromium
    inkscape
    firefox
    discord
    vesktop
    krita
    vmpk
    peek
    vlc
    mpv
  ];

}