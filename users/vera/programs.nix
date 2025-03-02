{ pkgs, ... }:

{

  programs.git = {
    enable = true;
    userName = "Vera Aguilera Puerto";
    userEmail = "gradientvera@outlook.com";
    extraConfig = {
      init = {
        defaultBranch = "main";
      };
    };
  };

  home.packages = with pkgs; [
    
  ];

}