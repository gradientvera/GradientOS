{ ... }:
{

  services.postgresql = {
    enable = true;
    ensureDatabases = [
      "hass"
    ];
    ensureUsers = [
      {
        name = "hass";
        ensureDBOwnership = true;
      }
    ];
  };

}