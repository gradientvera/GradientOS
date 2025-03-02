{ ... }:

{

  # Xbox one controller bluetooth workaround
  hardware.xpadneo.enable = true;
  boot.extraModprobeConfig = '' options bluetooth disable_ertm=1 '';

}