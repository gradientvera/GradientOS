{
  lib,
  pkgs,
  ...
}:
let
  user = "vera";

  steam = lib.getExe pkgs.steam;
  esde = lib.getExe pkgs.emulationstation-de;
in
{
  services.moonshine = {
    enable = true;
    user = user;

    extraPackages = [
      pkgs.steam
      pkgs.emulationstation-de
    ];

    firewallInterfaces = [
      "gradientnet"
      "tailscale0"
    ];

    settings = {
      name = "bernkastel";
      address = "0.0.0.0";

      application = [
        {
          title = "Steam Big Picture";
          command = [
            steam
            "steam://open/bigpicture"
          ];
        }
        {
          title = "ES-DE";
          command = [ esde ];
        }
      ];

      application_scanner = [
        {
          type = "steam";
          library = "$HOME/.local/share/Steam";
          command = [
            steam
            "-bigpicture"
            "steam://rungameid/{game_id}"
          ];
        }
      ];

      compositor = {
        steam_mode = true;
        hdr = true;
        keyboard.layout = "es";
      };
    };
  };
}
