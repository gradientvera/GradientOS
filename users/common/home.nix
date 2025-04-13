{ self, ... }:

{

  imports = [
    self.inputs.catppuccin.homeModules.catppuccin

    ./nix.nix
    ./nix-direnv.nix
  ];

  systemd.user.startServices = true;
  
  xdg.configFile."nixpkgs/config.nix".source = ./misc/nixpkgs-config.nix;
  
}