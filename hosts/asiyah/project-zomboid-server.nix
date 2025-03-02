{ config, pkgs, lib, ... }:
let
	steam-app = "380870";
  ports = import ./misc/service-ports.nix;
in {

	users.users.project-zomboid = {
		isSystemUser = true;
		home = "/var/lib/project-zomboid";
		createHome = true;
		homeMode = "750";
		group = config.users.groups.project-zomboid.name;
	};

	users.groups.project-zomboid = {};

	systemd.services.project-zomboid = {
		wantedBy = [ "multi-user.target" ];

		# Install the game before launching.
		wants = [ "steamcmd@${steam-app}.service" ];
		after = [ "steamcmd@${steam-app}.service" ];

		serviceConfig = {
			ExecStart = lib.escapeShellArgs [
        "${pkgs.steam-run}/bin/steam-run"
				"/var/lib/steamcmd/apps/${steam-app}/start-server.sh"
        "--servername Asiyah"
        "--port ${toString ports.project-zomboid}"
        "--udpport ${toString ports.project-zomboid-direct}"
        "--steamport1 ${toString ports.project-zomboid-steam-1}"
        "--steamport2 ${toString ports.project-zomboid-steam-2}"
			];
			Nice = "-5";
			PrivateTmp = true;
			Restart = "always";
			User = config.users.users.project-zomboid.name;
			WorkingDirectory = "~";
		};
		environment = {
			SteamAppId = "108600";
		};
	};

  networking.firewall.allowedTCPPorts = with ports; [
    project-zomboid
    project-zomboid-direct
    project-zomboid-steam-1
    project-zomboid-steam-2
  ];

  networking.firewall.allowedUDPPorts = with ports; [
    project-zomboid
    project-zomboid-direct
    project-zomboid-steam-1
    project-zomboid-steam-2
  ];
}