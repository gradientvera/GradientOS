{ ... }:
{

  # As per https://jellyfin.org/docs/general/post-install/networking/advanced/fail2ban
  environment.etc."fail2ban/filter.d/jellyfin.conf".text = ''
    [Definition]
    failregex = ^.*Authentication request for .* has been denied \(IP: "<ADDR>"\)\.
  '';


}