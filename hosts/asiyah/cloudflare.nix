{ config, ... }:
{

  services.ddclient = {
    enable = true;
    verbose = true;
    protocol = "cloudflare";
    ssl = true;
    username = "token";
    usev4 = "webv4, webv4=https://cloudflare.com/cdn-cgi/trace, web-skip='ip='";
    usev6 = "disabled"; # ISP does not support ipv6 :(
    passwordFile = config.sops.secrets.cfdyndns-token.path;
    extraConfig = ''
      zone=gradient.moe
      gradient.moe,
      *.gradient.moe,
      game.gradient.moe,
      vpn.gradient.moe,
      www.gradient.moe

      zone=zumorica.es
      zumorica.es,
      *.zumorica.es,
      www.zumorica.es

      zone=constellation.moe
      constellation.moe,
      *.constellation.moe,
      ftp.constellation.moe,
      www.constellation.moe
    '';
  };

}