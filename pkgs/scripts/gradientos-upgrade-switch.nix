{ writeShellApplication, nixos-rebuild, ... }:

writeShellApplication {
  name = "gradientos-upgrade-switch";

  runtimeInputs = [ nixos-rebuild ];

  text = ''
    sudo nixos-rebuild switch --flake "git+https://github.com/gradientvera/GradientOS" --show-trace --refresh -L "$@"
  '';
}