{ config, pkgs, ... }:

{

  home.file = {
    ".local/share/konsole/vera.colorscheme".source = ./vera.colorscheme;

    # Taken from https://raw.githubusercontent.com/catppuccin/konsole/3b64040e3f4ae5afb2347e7be8a38bc3cd8c73a8/themes/catppuccin-mocha.colorscheme
    # Modified to my liking!
    ".local/share/konsole/catppuccin-mocha.colorscheme".source = ./catppuccin-mocha.colorscheme;


    ".local/share/konsole/vera.profile".source = ./vera.profile;
    ".config/konsolerc".source = ./konsolerc;
  };

}