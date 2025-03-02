{ writeShellApplication, nixos-rebuild, ... }:

writeShellApplication {
  name = "gradientos-upgrade-test";

  runtimeInputs = [ nixos-rebuild ];

  text = ''
    sudo nixos-rebuild test --flake "git+https://github.com/gradientvera/GradientOS" --show-trace --refresh -L "$@"
  '';
}