{ ... }:
let
  ports = config.gradient.currentHost.ports;
in
{

  services.victoriametrics = {
    enable = true;
    listenAddress = ":${toString ports.victoriametrics}";
  };

}