{ pkgs, ... }:
let
  ports = import ../misc/service-ports.nix;
in {

  imports = [
    ./crp3092.nix
    ./vdo-ninja.nix
    ./gradientnet.nix
    ./gradient-moe.nix
    ./constellation-moe.nix
    ./constellation-moe-internal.nix
    ./constellation-moe-oauth2-proxy.nix
  ];

  services.nginx = {
    enable = true;
    package = pkgs.nginxStable.override {
      withSlice = true;
    };
    defaultHTTPListenPort = ports.nginx;
    defaultSSLListenPort = ports.nginx-ssl;
    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;
  };

  security.acme = {
    acceptTerms = true;
    defaults = {
      email = "gradientvera+acme@outlook.com";
    };
  };

  networking.firewall.allowedTCPPorts = with ports; [
    nginx nginx-ssl
  ];

}