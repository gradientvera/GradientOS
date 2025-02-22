{ config, lib, pkgs, ... }:
let
  cfg = config.gradient;
  tmpFilesRule = {
    user = cfg.profiles.gaming.emulation.user;
    group = cfg.profiles.gaming.emulation.group;
    mode = "0777";
  };
  home = config.users.users.${cfg.profiles.gaming.emulation.user}.home;
  romPath = cfg.profiles.gaming.emulation.romPath;
  devices = cfg.profiles.gaming.emulation.sync.devices;
  ESDEDataPath = "${home}/.local/share/ES-DE";
in 
{

  options = {
    gradient.profiles.gaming.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Whether to enable the GradientOS gaming profile.
        Includes some common videogames and nice performance tweaks.
      '';
    };

    gradient.profiles.gaming.openFirewall = lib.mkOption {
      type = lib.types.bool;
      default = cfg.profiles.gaming.enable;
      description = ''
        Whether to open ports 7777 to 7787 and ports 25565 to 25566.
        Useful for hosting videogame servers and the like without having to modify the system config.
      '';
    };

    gradient.profiles.gaming.installGames = lib.mkOption {
      type = lib.types.bool;
      default = cfg.profiles.gaming.enable;
      description = ''
        Whether to install some games and game utilities that I, personally, like!
      '';
    };

    gradient.profiles.gaming.kernelTweaksEnabled = lib.mkOption {
      type = lib.types.bool;
      default = cfg.profiles.gaming.enable;
      description = ''
        Whether to tweak some kernel configuration for gaming, based on CryoUtilities.
      '';
    };

    # -- Emulation section --
    gradient.profiles.gaming.emulation.enable = lib.mkOption {
      type = lib.types.bool;
      default = cfg.profiles.gaming.enable;
      description = ''
        Whether to enable the emulation profile.
        Includes emulators and a way to sync ROMs and savegames.
      '';
    };

    gradient.profiles.gaming.emulation.installEmulators = lib.mkOption {
      type = lib.types.bool;
      default = cfg.profiles.gaming.emulation.enable;
      description = ''
        Whether to install emulators.
      '';
    };

    gradient.profiles.gaming.emulation.user = lib.mkOption {
      type = lib.types.str;
      default = "vera";
      description = ''
        User that will own the folders.
        Emulator configs are based on this user's home directory.
      '';
    };

    gradient.profiles.gaming.emulation.group = lib.mkOption {
      type = lib.types.str;
      default = "users";
      description = ''
        Group that will own the folders.
      '';
    };

    gradient.profiles.gaming.emulation.romPath = lib.mkOption {
      type = lib.types.path;
      description = ''
        Path to the folder where ROMs are stored.
      '';
    };

    gradient.profiles.gaming.emulation.sync.enable = lib.mkOption {
      type = lib.types.bool;
      default = cfg.profiles.gaming.enable;
      description = ''
        Whether to enable savedata synchronization, using Syncthing.
      '';
    };

    gradient.profiles.gaming.emulation.sync.devices = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ "asiyah" "bernkastel" "erika" "featherine" ];
      description = ''
        Syncthing devices with which to share the synced folders.
      '';
    };

    gradient.profiles.gaming.emulation.sync.roms.enable = lib.mkOption {
      type = lib.types.bool;
      default = cfg.profiles.gaming.emulation.sync.enable;
      description = ''
        Whether to enable ROM file synchronization, using Syncthing.
      '';
    };

    gradient.profiles.gaming.emulation.systems = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = cfg.profiles.gaming.emulation.defaultSystems;
      description = ''
        Folders under the base ROM folder to create and sync using Syncthing if enabled.
      '';
    };

    gradient.profiles.gaming.emulation.defaultSystems = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      readOnly = true;
      description = ''
        Default systems supported by ES-DE.
      '';
      default = [
        "3do"
        "adam"
        "ags"
        "amiga"
        "amiga1200"
        "amiga600"
        "amigacd32"
        "amstradcpc"
        "apple2"
        "apple2gs"
        "arcade"
        "arcadia"
        "archimedes"
        "arduboy"
        "astrocde"
        "atari2600"
        "atari5200"
        "atari7800"
        "atari800"
        "atarijaguar"
        "atarijaguarcd"
        "atarilynx"
        "atarist"
        "atarixe"
        "atomiswave"
        "bbcmicro"
        "c64"
        "cdimono1"
        "cdtv"
        "chailove"
        "channelf"
        "coco"
        "colecovision"
        "consolearcade"
        "cps"
        "cps1"
        "cps2"
        "cps3"
        "crvision"
        "daphne"
        "desktop"
        "doom"
        "dos"
        "dragon32"
        "dreamcast"
        "easyrpg"
        "electron"
        "emulators"
        "epic"
        "famicom"
        "fba"
        "fbneo"
        "fds"
        "flash"
        "fm7"
        "fmtowns"
        "gamate"
        "gameandwatch"
        "gamecom"
        "gamegear"
        "gb"
        "gba"
        "gbc"
        "gc"
        "genesis"
        "gmaster"
        "gx4000"
        "intellivision"
        "j2me"
        "kodi"
        "laserdisc"
        "lcdgames"
        "lowresnx"
        "lutris"
        "lutro"
        "macintosh"
        "mame"
        "mame-advmame"
        "mastersystem"
        "megacd"
        "megacdjp"
        "megadrive"
        "megadrivejp"
        "megaduck"
        "mess"
        "model2"
        "model3"
        "moto"
        "msx"
        "msx1"
        "msx2"
        "msxturbor"
        "mugen"
        "multivision"
        "n3ds"
        "n64"
        "n64dd"
        "naomi"
        "naomi2"
        "naomigd"
        "nds"
        "neogeo"
        "neogeocd"
        "neogeocdjp"
        "nes"
        "ngage"
        "ngp"
        "ngpc"
        "odyssey2"
        "openbor"
        "oric"
        "palm"
        "pc"
        "pc88"
        "pc98"
        "pcarcade"
        "pcengine"
        "pcenginecd"
        "pcfx"
        "pico8"
        "plus4"
        "pokemini"
        "ports"
        "ps2"
        "ps3"
        "ps4"
        "psp"
        "psvita"
        "psx"
        "pv1000"
        "quake"
        "samcoupe"
        "satellaview"
        "saturn"
        "saturnjp"
        "scummvm"
        "scv"
        "sega32x"
        "sega32xjp"
        "sega32xna"
        "segacd"
        "sfc"
        "sg-1000"
        "sgb"
        "snes"
        "snesna"
        "solarus"
        "spectravideo"
        "steam"
        "stv"
        "sufami"
        "supergrafx"
        "supervision"
        "supracan"
        "switch"
        "symbian"
        "tanodragon"
        "tg-cd"
        "tg16"
        "ti99"
        "tic80"
        "to8"
        "triforce"
        "trs-80"
        "type-x"
        "uzebox"
        "vectrex"
        "vic20"
        "videopac"
        "virtualboy"
        "vpinball"
        "vsmile"
        "wasm4"
        "wii"
        "wiiu"
        "windows"
        "windows3x"
        "windows9x"
        "wonderswan"
        "wonderswancolor"
        "x1"
        "x68000"
        "xbox"
        "xbox360"
        "zmachine"
        "zx81"
        "zxnext"
        "zxspectrum"
      ];
    };

  };

  config = lib.mkMerge [
    (lib.mkIf cfg.profiles.gaming.enable {
      gradient.profiles.desktop.enable = true;
    })

    (lib.mkIf (cfg.profiles.gaming.enable && cfg.profiles.gaming.openFirewall) {
      # For games and such.
      networking.firewall.allowedTCPPortRanges = [ { from=7777; to=7787; } ];
      networking.firewall.allowedUDPPortRanges = [ { from=7777; to=7787; } ];
    })

    (lib.mkIf (cfg.profiles.gaming.enable && cfg.profiles.gaming.installGames) {
      # Conflicting definition for capSysNice behavior
      programs.gamescope = if (config ? "jovian" && config.jovian.steam.enable) then {
        enable = true;
      }
      else {
        enable = true;
        capSysNice = true;
      };

      programs.gamemode.enable = true;

      # Remote gaming hell yeah! Must be started manually for "security"
      services.sunshine = {
        enable = true;
        capSysAdmin = true;
        openFirewall = true;
        autoStart = lib.mkDefault false;
      };
      
      environment.systemPackages = with pkgs; [
        space-station-14-launcher
        osu-lazer-bin
        prismlauncher
        xivlauncher
        steam-run
        heroic
        lutris
      ];
    })

    (lib.mkIf (cfg.profiles.gaming.enable && cfg.profiles.gaming.kernelTweaksEnabled) {
      # Performance tweaks based on CryoUtilities
      gradient.kernel = {
        hugepages = {
          enable = true;
          defrag = "0";
          sharedMemory = "advise";
        };
        swappiness = 1;
        pageLockUnfairness = 1;
        compactionProactiveness = 0;
      };
    })

    (lib.mkIf cfg.profiles.gaming.emulation.enable {
      # Create needed folders for ROM path etc
      systemd.tmpfiles.settings."10-emulation.conf" = 
      {
        "${ESDEDataPath}".d = tmpFilesRule;
        "${romPath}".d = tmpFilesRule;
      } // (builtins.listToAttrs
        (builtins.map
          (f: { name = "${romPath}/${f}"; value = { d = tmpFilesRule; }; })
          cfg.profiles.gaming.emulation.systems));
    })

    (lib.mkIf cfg.profiles.gaming.emulation.installEmulators {
      environment.systemPackages = with pkgs; [
        # -- Retroarch --
        retroarch-full # A lot of systems
        # -- Standalone emulators --
        stable.lime3ds # 3DS
        dolphin-emu # Wii / GC
        cemu # WiiU
        ryubing # Switch
        pcsx2 # PS2
        rpcs3 # PS3
        shadps4 # PS4
        ruffle # Flash
        # -- Utilities --
        (emulationstation-de.overrideAttrs (prevAttrs: {
          nativeBuildInputs = prevAttrs.nativeBuildInputs ++ [ makeWrapper ];
          postInstall = ''
            wrapProgram $out/bin/es-de --set ESDE_APPDATA_DIR ${ESDEDataPath}
          '';
        }))
      ];
    })

    (lib.mkIf (cfg.profiles.gaming.emulation.sync.enable)
    ({
      # Create needed folders for syncing
      systemd.tmpfiles.settings."10-emulation.conf" = 
      {
        # Retroarch
        "${home}/.config/retroarch".d = tmpFilesRule;
        "${home}/.config/retroarch/system".d = tmpFilesRule;
        "${home}/.config/retroarch/system/.stfolder".d = tmpFilesRule;
        "${home}/.config/retroarch/saves".d = tmpFilesRule;
        "${home}/.config/retroarch/saves/.stfolder".d = tmpFilesRule;
        "${home}/.config/retroarch/states".d = tmpFilesRule;
        "${home}/.config/retroarch/states/.stfolder".d = tmpFilesRule;
        # ES-DE
        "${ESDEDataPath}/gamelists".d = tmpFilesRule;
        "${ESDEDataPath}/downloaded_media".d = tmpFilesRule;
        # Ryujinx
        "${home}/.config/Ryujinx".d = tmpFilesRule;
        "${home}/.config/Ryujinx/system".d = tmpFilesRule;
        "${home}/.config/Ryujinx/system/.stfolder".d = tmpFilesRule;
        "${home}/.config/Ryujinx/profiles".d = tmpFilesRule;
        "${home}/.config/Ryujinx/profiles/.stfolder".d = tmpFilesRule;
        "${home}/.config/Ryujinx/sdcard".d = tmpFilesRule;
        "${home}/.config/Ryujinx/sdcard/.stfolder".d = tmpFilesRule;
        "${home}/.config/Ryujinx/bis".d = tmpFilesRule;
        "${home}/.config/Ryujinx/bis/.stfolder".d = tmpFilesRule;
        # Lime3DS
        "${home}/.local/share/lime3ds-emu".d = tmpFilesRule;
        "${home}/.local/share/lime3ds-emu/nand".d = tmpFilesRule;
        "${home}/.local/share/lime3ds-emu/nand/.stfolder".d = tmpFilesRule;
        "${home}/.local/share/lime3ds-emu/sdmc".d = tmpFilesRule;
        "${home}/.local/share/lime3ds-emu/sdmc/.stfolder".d = tmpFilesRule;
        "${home}/.local/share/lime3ds-emu/sysdata".d = tmpFilesRule;
        "${home}/.local/share/lime3ds-emu/sysdata/.stfolder".d = tmpFilesRule;
        # Dolphin
        "${home}/.local/share/dolphin-emu".d = tmpFilesRule;
        "${home}/.local/share/dolphin-emu/Wii".d = tmpFilesRule;
        "${home}/.local/share/dolphin-emu/Wii/.stfolder".d = tmpFilesRule;
        "${home}/.local/share/dolphin-emu/GC".d = tmpFilesRule;
        "${home}/.local/share/dolphin-emu/GC/.stfolder".d = tmpFilesRule;
        "${home}/.local/share/dolphin-emu/Load".d = tmpFilesRule;
        "${home}/.local/share/dolphin-emu/Load/.stfolder".d = tmpFilesRule;
        "${home}/.local/share/dolphin-emu/StateSaves".d = tmpFilesRule;
        "${home}/.local/share/dolphin-emu/StateSaves/.stfolder".d = tmpFilesRule;
        # Cemu
        "${home}/.local/share/Cemu".d = tmpFilesRule;
        "${home}/.local/share/Cemu/mlc01".d = tmpFilesRule;
        "${home}/.local/share/Cemu/mlc01/.stfolder".d = tmpFilesRule;
        # PCSX2
        "${home}/.config/PCSX2".d = tmpFilesRule;
        "${home}/.config/PCSX2/bios".d = tmpFilesRule;
        "${home}/.config/PCSX2/bios/.stfolder".d = tmpFilesRule;
        "${home}/.config/PCSX2/sstates".d = tmpFilesRule;
        "${home}/.config/PCSX2/sstates/.stfolder".d = tmpFilesRule;
        "${home}/.config/PCSX2/memcards".d = tmpFilesRule;
        "${home}/.config/PCSX2/memcards/.stfolder".d = tmpFilesRule;
        # RPCS3
        "${home}/.config/rpcs3".d = tmpFilesRule;
        "${home}/.config/rpcs3/dev_hdd0".d = tmpFilesRule;
        "${home}/.config/rpcs3/dev_hdd0/.stfolder".d = tmpFilesRule;
        "${home}/.config/rpcs3/dev_flash".d = tmpFilesRule;
        "${home}/.config/rpcs3/dev_flash/.stfolder".d = tmpFilesRule;
        "${home}/.config/rpcs3/dev_usb000".d = tmpFilesRule;
        "${home}/.config/rpcs3/dev_usb000/.stfolder".d = tmpFilesRule;
        "${home}/.config/rpcs3/savestates".d = tmpFilesRule;
        "${home}/.config/rpcs3/savestates/.stfolder".d = tmpFilesRule;
        # shadPS4
        "${home}/.local/share/shadPS4".d = tmpFilesRule;
        "${home}/.local/share/shadPS4/savedata".d = tmpFilesRule;
        "${home}/.local/share/shadPS4/savedata/.stfolder".d = tmpFilesRule;
      };

      gradient.presets.syncthing.folders = {
        # Retroarch
        retroarch-system = {
          inherit devices;
          id = "retroarch-system";
          versioning.type = "trashcan";
          path = "${home}/.config/retroarch/system";
        };
        retroarch-saves = {
          inherit devices;
          id = "retroarch-saves";
          versioning.type = "trashcan";
          path = "${home}/.config/retroarch/saves";
        };
        retroarch-states = {
          inherit devices;
          id = "retroarch-states";
          versioning.type = "trashcan";
          path = "${home}/.config/retroarch/states";
        };
        # ES-DE
        es-de-gamelists = {
          inherit devices;
          id = "es-de-gamelists";
          versioning.type = "trashcan";
          path = "${ESDEDataPath}/gamelists";
        };
        es-de-downloaded-media = {
          inherit devices;
          id = "es-de-downloaded-media";
          versioning.type = "trashcan";
          path = "${ESDEDataPath}/downloaded_media";
        };
        # Ryujinx
        ryujinx-system = {
          inherit devices;
          id = "ryujinx-system";
          versioning.type = "trashcan";
          path = "${home}/.config/Ryujinx/system";
        };
        ryujinx-profiles = {
          inherit devices;
          id = "ryujinx-profiles";
          versioning.type = "trashcan";
          path = "${home}/.config/Ryujinx/profiles";
        };
        ryujinx-sdcard = {
          inherit devices;
          id = "ryujinx-sdcard";
          versioning.type = "trashcan";
          path = "${home}/.config/Ryujinx/sdcard";
        };
        ryujinx-bis = {
          inherit devices;
          id = "ryujinx-bis";
          versioning.type = "trashcan";
          path = "${home}/.config/Ryujinx/bis";
        };
        # Lime3DS
        lime3ds-nand = {
          inherit devices;
          id = "lime3ds-nand";
          versioning.type = "trashcan";
          path = "${home}/.local/share/lime3ds-emu/nand";
        };
        lime3ds-sdmc = {
          inherit devices;
          id = "lime3ds-sdmc";
          versioning.type = "trashcan";
          path = "${home}/.local/share/lime3ds-emu/sdmc";
        };
        lime3ds-sysdata = {
          inherit devices;
          id = "lime3ds-sysdata";
          versioning.type = "trashcan";
          path = "${home}/.local/share/lime3ds-emu/sysdata";
        };
        # Dolphin
        dolphin-wii = {
          inherit devices;
          id = "dolphin-wii";
          versioning.type = "trashcan";
          path = "${home}/.local/share/dolphin-emu/Wii";
        };
        dolphin-gc = {
          inherit devices;
          id = "dolphin-gc";
          versioning.type = "trashcan";
          path = "${home}/.local/share/dolphin-emu/GC";
        };
        dolphin-load = {
          inherit devices;
          id = "dolphin-load";
          versioning.type = "trashcan";
          path = "${home}/.local/share/dolphin-emu/Load";
        };
        dolphin-statesaves = {
          inherit devices;
          id = "dolphin-statesaves";
          versioning.type = "trashcan";
          path = "${home}/.local/share/dolphin-emu/StateSaves";
        };
        # Cemu
        cemu-mlc01 = {
          inherit devices;
          id = "cemu-mlc01";
          versioning.type = "trashcan";
          path = "${home}/.local/share/Cemu/mlc01";
        };
        # PCSX2
        pcsx2-bios = {
          inherit devices;
          id = "pcsx2-bios";
          versioning.type = "trashcan";
          path = "${home}/.config/PCSX2/bios";
        };
        pcsx2-sstates = {
          inherit devices;
          id = "pcsx2-sstates";
          versioning.type = "trashcan";
          path = "${home}/.config/PCSX2/sstates";
        };
        pcsx2-memcards = {
          inherit devices;
          id = "pcsx2-memcards";
          versioning.type = "trashcan";
          path = "${home}/.config/PCSX2/memcards";
        };
        # RPCS3
        rpcs3-dev-hdd0 = {
          inherit devices;
          id = "rpcs3-dev-hdd0";
          versioning.type = "trashcan";
          path = "${home}/.config/rpcs3/dev_hdd0";
        };
        rpcs3-dev-flash = {
          inherit devices;
          id = "rpcs3-dev-flash";
          versioning.type = "trashcan";
          path = "${home}/.config/rpcs3/dev_flash";
        };
        rpcs3-dev-usb000 = {
          inherit devices;
          id = "rpcs3-dev-usb000";
          versioning.type = "trashcan";
          path = "${home}/.config/rpcs3/dev_usb000";
        };
        rpcs3-savestates = {
          inherit devices;
          id = "rpcs3-savestates";
          versioning.type = "trashcan";
          path = "${home}/.config/rpcs3/savestates";
        };
        # shadPS4
        shadps4-savedata = {
          inherit devices;
          id = "shadps4-savedata";
          versioning.type = "trashcan";
          path = "${home}/.local/share/shadPS4/savedata";
        };
      };
    }))

    (lib.mkIf (cfg.profiles.gaming.emulation.sync.roms.enable) {
      gradient.presets.syncthing.folders = let
        mkSyncFolder = f: {
          inherit devices;
          id = "roms-${f}";
          versioning.type = "trashcan";
          path = "${romPath}/${f}";
          copyOwnershipFromParent = true;
        };
      in builtins.listToAttrs 
        (builtins.map
          (f: { name = "roms-${f}"; value = mkSyncFolder f; })
          cfg.profiles.gaming.emulation.systems);

      # Generate syncthing markers for ROM folders.
      systemd.tmpfiles.settings."10-emulation.conf" = builtins.listToAttrs
        (builtins.map
          (f: { name = "${romPath}/${f}/.stfolder"; value = { d = tmpFilesRule; }; })
          cfg.profiles.gaming.emulation.systems);
    })
  ];

}