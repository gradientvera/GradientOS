{ pkgs, ... }:

{

  imports = [
    ./konsole/default.nix
  ];

  home.packages = with pkgs; [
    stable.gimp-with-plugins
    stable.libreoffice-fresh
    jellyfin-media-player
    lxqt.pavucontrol-qt
    whatsapp-for-linux
    kdePackages.okular
    element-desktop
    master.discord-canary
    kdePackages.kate
    google-chrome
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
    carla
    vmpk
    peek
    vlc
    mpv
  ];

  programs.obs-studio = {
    enable = true;
    plugins = with pkgs.obs-studio-plugins; [
      obs-vkcapture
      obs-vaapi
    ];
  };

}