{ ... }:
{

  # As per https://www.home-assistant.io/integrations/fail2ban/
  environment.etc."fail2ban/filter.d/hass.conf".text = ''
    [INCLUDES]
    before = common.conf

    [Definition]
    failregex = ^%(__prefix_line)s.*Login attempt or request with invalid authentication from <HOST>.*$

    ignoreregex =

    [Init]
    datepattern = ^%%Y-%%m-%%d %%H:%%M:%%S
  '';

}