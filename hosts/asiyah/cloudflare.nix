{ config, ... }:
{

  services.ddclient = {
    enable = true;
    protocol = "cloudflare";
    use = "web";
    ssl = true;
    passwordFile = config.sops.secrets.cfdyndns-token.path;
    extraConfig = ''
      web='https://cloudflare.com/cdn-cgi/trace'
      web-skip='ip='

      zone=gradient.moe
      gradient.moe
      *.gradient.moe
      game.gradient.moe
      vpn.gradient.moe
      www.gradient.moe

      zone=zumorica.es
      zumorica.es
      *.zumorica.es
      www.zumorica.es

      zone=constellation.moe
      constellation.moe
      *.constellation.moe
      ftp.constellation.moe
      www.constellation.moe
    '';
  };

}