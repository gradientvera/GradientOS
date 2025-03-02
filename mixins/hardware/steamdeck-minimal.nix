{ pkgs, ... }:
{

  # Enable hardware and Steam support.
  jovian.devices.steamdeck.enable = true;
  jovian.devices.steamdeck.autoUpdate = true;
  jovian.devices.steamdeck.enableXorgRotation = false;

  environment.systemPackages = with pkgs; [
    galileo-mura
    steamdeck-firmware
    jupiter-dock-updater-bin
  ];

  # Automount SD card.
  fileSystems."/run/media/deck/mmcblk0p1" = {
    device = "/dev/mmcblk0p1";
    options = [ "defaults" "rw" "nofail" "x-systemd.automount" "x-systemd.device-timeout=1ms" "comment=x-gvfs-show" ];
  };

  # Symlink old Steam Deck SD card path to new one.
  systemd.tmpfiles.rules = [ "L+ /run/media/mmcblk0p1 - - - - /run/media/deck/mmcblk0p1" ];

}