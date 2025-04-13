{ ... }:
{

  # As per https://notes.abhinavsarkar.net/2022/fail2ban-nginx-cloudflare-nixos
  environment.etc."fail2ban/filter.d/nginx-noagent.conf".text = ''
    [Definition]

    failregex = ^<HOST> -.*"-" "-"$

    ignoreregex =
  '';

}