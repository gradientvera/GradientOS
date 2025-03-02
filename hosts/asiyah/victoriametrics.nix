{ ... }:
let
  ports = import ./misc/service-ports.nix;
in
{

  services.victoriametrics = {
    enable = true;
    listenAddress = ":${toString ports.victoriametrics}";
  };

}