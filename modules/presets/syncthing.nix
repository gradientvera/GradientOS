{ config, lib, ... }:
let
  cfg = config.gradient.presets.syncthing;
  secrets = config.sops.secrets;
  deviceIds = config.gradient.const.syncthing.deviceIds;
  hostName = config.networking.hostName;
in
{

  options = {
    gradient.presets.syncthing.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Whether to enable the Syncthing configuration preset.
      '';
    };

    gradient.presets.syncthing.user = lib.mkOption {
      type = lib.types.str;
      default = "vera";
      description = ''
        User to run the Syncthing service as.
      '';
    };

    gradient.presets.syncthing.dataDir = lib.mkOption {
      type = lib.types.str;
      default = "/home/${cfg.user}";
      description = ''
        Path to the default data directory for Syncthing.
      '';
    };

    gradient.presets.syncthing.configDir = lib.mkOption {
      type = lib.types.str;
      default = "/home/${cfg.user}/.config/syncthing";
      description = ''
        Path to the default config directory for Syncthing.
      '';
    };

    gradient.presets.syncthing.cert = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = if cfg.enable then secrets.syncthing-cert.path else null;
      description = ''
        Path to the certificate file.
      '';
    };

    gradient.presets.syncthing.key = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = if cfg.enable then secrets.syncthing-key.path else null;
      description = ''
        Path to the key file.
      '';
    };
  };

  config = lib.mkMerge ([
    # General config
    (lib.mkIf (cfg.enable) {
      services.syncthing = {
        enable = true;
        user = cfg.user;
        dataDir = cfg.dataDir;
        configDir = cfg.configDir;
        cert = cfg.cert;
        key = cfg.key;
        overrideFolders = true;
        overrideDevices = true;
        openDefaultPorts = true;
        guiAddress = "0.0.0.0:8384";

        settings = {
          devices = (builtins.removeAttrs (builtins.mapAttrs (_: value: { id = builtins.toString value; }) deviceIds) [ hostName ]);
          options = {
            localAnnounceEnabled = true;
            limitBandwidthInLan = false;
            urAccepted = -1;
          };
        };
      };

      networking.firewall.interfaces.gradientnet.allowedTCPPorts = [ 22000 21027 8384 ];
      networking.firewall.interfaces.gradientnet.allowedUDPPorts = [ 22000 21027 8384 ];
    })
  ] ++ (lib.attrsets.mapAttrsToList (name: value: (lib.mkIf (cfg.enable && builtins.any (v: v == hostName) value.devices) {
    services.syncthing.settings.folders.${name} = value 
      // { devices = builtins.filter (v: v != hostName) value.devices; };
      # ^ Remove the current machine from the devices ^
  })) 
  {
    default = {
      id = "default";
      versioning.type = "trashcan";
      path = "~/Documents/Sync";
      devices = [ "bernkastel" "beatrice" "erika" "asiyah" "briah" "vera-phone" "work-laptop" "featherine" "ange" ];
    };
    music = {
      id = "y0fft-chww4";
      versioning.type = "trashcan";
      path = "~/Music";
      devices = [ "bernkastel" "beatrice" "erika" "asiyah" "vera-phone" "work-laptop" "featherine" "ange" ];
    };
    retrodeck = {
      id = "9rctd-ets59";
      versioning.type = "trashcan";
      path = config.gradient.lib.switch hostName [
        { case = "bernkastel"; value = "/data/retrodeck"; }
        { case = "featherine"; value = "/data/retrodeck"; }
        { case = "asiyah"; value = "/data/retrodeck"; }
        { case = "erika"; value = "/run/media/deck/mmcblk0p1/retrodeck"; }
        { case = null; value = throw "Did not match any hostname..."; }
      ];
      devices = [ "asiyah" "bernkastel" "erika" "featherine" ];
    };
    ffxiv-config = {
      id = "ujgmj-wkmsh";
      versioning.type = "trashcan";
      path = "~/.xlcore/ffxivConfig";
      devices = [ "bernkastel" "asiyah" "beatrice" "erika" "featherine" ];
    };
    the-midnight-hall = {
      id = "ykset-ue2ke";
      versioning.type = "trashcan";
      path = "~/Documents/TheMidnightHall";
      devices = [ "bernkastel" "asiyah" "featherine" "neith-deck" "hadal-rainbow" ];
    };
    important-documents = {
      id = "egytl-udh2q";
      versioning.type = "trashcan";
      path = "~/.ImportantDocuments_encfs/";
      devices = [ "bernkastel" "asiyah" ];
    };
  }));

}