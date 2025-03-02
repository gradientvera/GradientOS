{ ... }:
let
  ssh-pub-keys = import ../../misc/ssh-pub-keys.nix;
in {

  programs.ssh.enable = true;

  home.file.".ssh/id_ed25519.pub".text = ssh-pub-keys.vera;

}