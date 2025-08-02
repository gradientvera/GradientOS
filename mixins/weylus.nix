{ ... }:
{

  programs.weylus = {
    enable = true;
    users = [ "vera" ];
    openFirewall = true;
  };

}