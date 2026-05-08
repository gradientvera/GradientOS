{ pkgs, config, lib, ... }:

{

  imports = [
    ./programs.nix
    ./filesystems.nix
    ./secrets/default.nix
    ./hardware-configuration.nix
  ];

  networking.hostName = "neith-deck";

  gradient.profiles.gaming.enable = true;
  gradient.profiles.gaming.emulation.enable = true;
  gradient.profiles.gaming.emulation.romPath = "/run/media/deck/mmcblk0p1/roms";
  gradient.profiles.gaming.emulation.sync.devices = [];
  
  gradient.profiles.gaming.emulation.user = "neith";
  gradient.profiles.desktop.enable = true;
  gradient.profiles.catppuccin.enable = false;

  gradient.presets.syncthing.enable = true;
  gradient.presets.syncthing.user = "neith";

  services.handheld-daemon.enable = true;
  services.handheld-daemon.user = "neith";

  specialisation.deck-mode.configuration = {
    # Use Jovian's steam deck UI autostart.
    services.displayManager.plasma-login-manager.enable = lib.mkForce false;
    jovian.steam.autoStart = lib.mkForce true;
  };

  jovian.steam.user = "neith";
  jovian.steam.autoStart = false;
  jovian.decky-loader.user = "neith";
  jovian.steam.desktopSession = "plasma";

  gradient.substituters = {
    asiyah = "ssh-ng://nix-ssh@asiyah.lily?priority=50";
    bernkastel = "ssh-ng://nix-ssh@bernkastel.lily?priority=50";
    erika = "ssh-ng://nix-ssh@erika.lily?priority=50";
  };

  users.users.constellation = {
    isNormalUser = true;
    linger = true;
    description = "For the alt steam account";
    shell = pkgs.fish;
    extraGroups = [ "networkmanager" "audio" "video" "pipewire" "scanner" "lp" ];
    hashedPassword = "$6$7mwTIbQIbSE9s6h5$J1Z5xG3V5kY65pgSQKulKg5UpVUnKuHnZoXmZ98IMCRNXhLHWgEAbizz8g4d1IJvDMp/pLBl4EKK.0fzcyb6N0";
  };

  security.polkit.extraConfig = ''
    polkit.addRule(function(action, subject) {
        if (action.id == "org.freedesktop.machine1.host-shell" &&
            action.lookup("user") == "constellation" &&
            subject.user == "neith") {
                return polkit.Result.YES;
        }
    });
  '';

  environment.systemPackages = [
    (pkgs.runCommand "steam-alt-constellation" { } ''
      mkdir -p $out/share/applications
      cp ${pkgs.steam}/share/applications/steam.desktop $out/share/applications/steam-alt-constellation.desktop
      substituteInPlace $out/share/applications/steam-alt-constellation.desktop \
        --replace "Name=Steam" "Name=Steam (Constellation Alt)" \
        --replace "Exec=steam" "Exec=ego --user=constellation steam"
    '')
  ];

}