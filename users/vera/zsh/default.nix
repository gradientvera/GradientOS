{ ... }:

{

  imports = [
    ../../../mixins/home/zsh.nix
  ];
  
  programs.zsh.initExtra = builtins.readFile ./zshrc;

}