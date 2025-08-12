{ ... }:

{
  imports = [
    ./ssh.nix
    # ./nushell.nix
    ./programs.nix
    #./zsh/default.nix
    ./secrets/default.nix
  ];

  home.username = "vera";
  home.homeDirectory = "/home/vera";

  catppuccin.enable = true;
  catppuccin.flavor = "mocha";
  catppuccin.kvantum.enable = true;
  catppuccin.kvantum.apply = true;

  home.sessionPath = [
    "$HOME/bin"
  ];

  home.sessionVariables = {
    EDITOR = "nano";
    VISUAL = "nano";
  };

  xdg.userDirs = {
    enable = true;
    createDirectories = true;
  };

  programs.carapace.enable = true;

  home.file.".face".source = ./face.png;

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "22.11";

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}