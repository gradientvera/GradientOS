{ pkgs, ... }:

{

  services.printing = {
    enable = true;
    drivers = [ pkgs.brlaser pkgs.ptouch-driver ];
  };

  hardware.sane = {
    enable = true;
    openFirewall = true;
    extraBackends = [ pkgs.sane-airscan ];
    netConf = ''
      192.168.1.12
    '';
    brscan5 = {
      # enable = true; # TODO: Broken
      netDevices.brother = {
        model = "DCP-L2530DW";
        nodename = "BRW4CD5776D8616";
      };
    };
  };

  environment.systemPackages = with pkgs; [
    stable.xsane
  ];

}