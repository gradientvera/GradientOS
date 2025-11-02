{ pkgs, ... }:

{

  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "Vera Aguilera Puerto";
        email = "gradientvera@outlook.com";
      };
      init = {
        defaultBranch = "main";
      };
    };
  };

  home.packages = with pkgs; [
    
  ];

}