{ ports, ... }:
{

  services.victorialogs = {
    enable = true;
    listenAddress = ":${toString ports.victorialogs}";
    extraOptions = [
      "-retentionPeriod=30d"
      "-retention.maxDiskSpaceUsageBytes=128GiB"
    ];
  };

  networking.firewall.interfaces.gradientnet.allowedTCPPorts = [
    ports.victorialogs
  ];

}