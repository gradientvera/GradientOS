{ ... }:
{

  services.clamav = {
    daemon.enable = true;
    updater.enable = true;
    fangfrisch.enable = true;
    scanner.enable = true;
  };

}