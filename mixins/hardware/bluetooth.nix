{ pkgs, ... }:

{

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    package = pkgs.bluez-experimental;
    settings = {
      General = {
        Class = "0x000100";
        Enable = "Control,Gateway,Headset,Media,Sink,Socket,Source";
        ControllerMode = "dual";
        FastConnectable = true;
        Experimental = true;
        JustWorksRepairing = "always";
        Privacy = "device";
      };
      Policy = {
        ReconnectIntervals = "1,1,2,3,5,8,13,21,34,55";
        AutoEnable = true;
      };
      LE = {
        MinConnectionInterval = "7";
        MaxConnectionInterval = "9";
        ConnectionLatency = "0";
      };
    };
  };

  boot.extraModprobeConfig = ''
    # See https://gitlab.archlinux.org/archlinux/packaging/packages/bluez/-/blob/main/bluetooth.modprobe
    options btusb reset=1
  '';

}