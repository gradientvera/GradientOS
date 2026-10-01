{
  lib,
  pkgs,
  ...
}:
let
  user = "vera";

  steam = lib.getExe pkgs.steam;
  esde = lib.getExe pkgs.emulationstation-de;

  killSteam = pkgs.writeShellScriptBin "moonshine-steam-kill" ''
    ${pkgs.systemd}/bin/systemctl --user stop app-steam@autostart.service || true
  '';
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
      stream.timeout = 300;

      application = [
        {
          title = "Steam Big Picture";
          command = [
            steam
            "steam://open/bigpicture"
          ];
          pre_command = [ [ (lib.getExe killSteam) ] ];
        }
        {
          title = "ES-DE";
          command = [ esde ];
        }
      ];

      application_scanner = [
        # Honestly I like steam big screen better. lol-
        /*{
          type = "steam";
          library = "$HOME/.local/share/Steam";
          command = [
            steam
            "-bigpicture"
            "steam://rungameid/{game_id}"
          ];
          pre_command = [ [ (lib.getExe killSteam) ] ];
        }*/
      ];

      compositor = {
        steam_mode = true;
        hdr = true;
        keyboard.layout = "es";
      };
    };
  };
}
