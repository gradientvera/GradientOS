{ writeShellApplication, coreutils, ... }:

writeShellApplication {
  name = "force-xwayland";

  runtimeInputs = [ coreutils ];

  text = ''
    env -a NIXOS_OZONE_WL=0 -a XDG_SESSION_TYPE=x11 -u WAYLAND_DISPLAY -u GDK_BACKEND -u QT_QPA_PLATFORM "$@"
  '';
}