{ pkgs, ... }:

{

  imports = [
    ./konsole/default.nix
  ];

  home.packages = with pkgs; [
    jellyfin-media-player
    lxqt.pavucontrol-qt
    whatsapp-for-linux
    kdePackages.okular
    libreoffice-fresh
    gimp-with-plugins
    element-desktop
    master.discord-canary
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

  programs.obs-studio = {
    enable = true;
    plugins = with pkgs.obs-studio-plugins; [
      obs-vkcapture
      obs-vaapi
    ];
  };

}