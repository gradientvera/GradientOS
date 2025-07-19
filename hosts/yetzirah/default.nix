{ ... }:
{
 
  imports = [
    ./filesystem.nix
    ./secrets/default.nix
    ./hardware-configuration.nix
  ];  

  gradient.profiles.catppuccin.enable = true;
  gradient.profiles.graphics.enable = true;
  gradient.kernel.hugepages.enable = true;

}