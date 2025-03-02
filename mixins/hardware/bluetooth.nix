{ pkgs, ... }:

{

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    package = pkgs.bluez-experimental;
    settings = {
      General = {
        Class = "0x000100";
        ControllerMode = "dual";
        FastConnectable = true;
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

}