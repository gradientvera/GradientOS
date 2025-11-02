{ lib, pkgs, ... }:

{

  services.pcscd.enable = true;

  programs.gnupg.agent = {
    enable = true;
  };

  environment.systemPackages = with pkgs; [
    gnupg
    pinentry-curses
  ];
}