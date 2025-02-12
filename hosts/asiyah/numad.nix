{ pkgs, ... }:
{

  systemd.services.numad = {
    description = "numad - The NUMA daemon that manages application locality.";
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "forking";
      ExecStart = "${pkgs.numad}/bin/numad -i 15";
      Restart = "on-failure";
    };
  };

}