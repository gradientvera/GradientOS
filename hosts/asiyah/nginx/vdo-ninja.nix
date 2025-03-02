{ self, ... }:
let
  vdo-ninja = self.inputs.vdo-ninja;
  ports = import ../misc/service-ports.nix;
  ips = import ../../../misc/wireguard-addresses.nix;
in {

  services.nginx.virtualHosts."vdo-ninja" = {
    root = vdo-ninja;
    listen = [{
      addr = "127.0.0.1";
      port = ports.vdo-ninja;
    }];
    extraConfig = ''
      index index.html;
    '';
    locations."~ ^/([^/]+)/([^/?]+)$" = {
      extraConfig = ''
        root ${vdo-ninja};
        try_files /$1/$2 /$1/$2.html /$1/$2/ /$2 /$2/ /$1/index.html;
        add_header Access-Control-Allow-Origin *;
      '';
    };
    locations."/" = {
      extraConfig = ''
        if ($request_uri ~ ^/(.*)\.html$) {
                return 302 /$1;
        }
        try_files $uri $uri.html $uri/ /index.html;
        add_header Access-Control-Allow-Origin *;
      '';
    };
  };

}