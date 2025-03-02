{ writeShellApplication, colmena, ... }:

writeShellApplication {
  name = "gradientos-colmena";

  runtimeInputs = [ colmena ];

  text = ''
    colmena -f "git+https://github.com/gradientvera/GradientOS" --show-trace "$@"
  '';
}