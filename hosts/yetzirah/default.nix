{ ... }:
{
 
  imports = [
    ./filesystem.nix
    ./secrets/default.nix
    ./hardware-configuration.nix
  ];  

  gradient.profiles.catppuccin.enable = true;
  gradient.profiles.graphics.enable = true;
  gradient.kernel.transparent_hugepages.enable = true;

}