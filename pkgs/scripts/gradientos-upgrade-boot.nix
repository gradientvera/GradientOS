{ writeShellApplication, nixos-rebuild, ... }:

writeShellApplication {
  name = "gradientos-upgrade-boot";

  runtimeInputs = [ nixos-rebuild ];

  text = ''
    sudo nixos-rebuild boot --flake "git+https://github.com/gradientvera/GradientOS" --show-trace --refresh -L "$@"
  '';
}