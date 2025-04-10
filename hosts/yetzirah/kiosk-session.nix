{ pkgs, ... }:
let
  ports = config.gradient.currentHost.ports;
in {

  services.cage = {
    enable = true;
    user = "vera";
    program = pkgs.writeScript "cage-script" ''
      ${pkgs.unstable.wlr-randr}/bin/wlr-randr --output DP-1 --mode 800x480@68.349998Hz
      ${pkgs.unstable.chromium}/bin/chromium --noerrdialogs --disable-infobars --incognito --kiosk http://127.0.0.1:${toString ports.mainsail}
    '';
    extraArguments = [ "-d" ];
  };

  systemd.services."cage-tty1".after = [ "nginx.service" "moonraker.service" ];

  systemd.services."serial-getty@ttyS0".enable = false;
  systemd.services."serial-getty@hvc0".enable = false;
  systemd.services."getty@tty1".enable = false;
  systemd.services."autovt@".enable = false;

}