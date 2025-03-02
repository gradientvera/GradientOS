{ config, lib, pkgs, ... }:
let
  cfg = config.gradient;
in
{
  options = {
    gradient.profiles.audio.um2.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Whether to enable support for the UM2 USB audio card.
        Requires the audio profile to be enabled.
      '';
    };
  };

  config = lib.mkMerge [
    (lib.mkIf (cfg.profiles.audio.enable && cfg.profiles.audio.um2.enable) {
      services.pipewire.extraConfig.pipewire."10-um2.conf" = {
        "context.modules" = [
            {   "name" = "libpipewire-module-filter-chain";
                "args" = {
                    "node.description" = "UM2 Microphone";
                    "media.name" = "UM2 Microphone";
                    "filter.graph" = {
                        "nodes" = [
                            {
                                "name"   = "copyIL";
                                "type"   = "builtin";
                                "label"  = "copy";
                            }
                            {
                                "name"   = "copyOL";
                                "type"   = "builtin";
                                "label"  = "copy";
                            }
                            {
                                "name"   = "copyOR";
                                "type"   = "builtin";
                                "label"  = "copy";
                            }
                        ];
                        "links" = [
                            { "output" = "copyIL:Out"; "input" = "copyOL:In"; }
                            { "output" = "copyIL:Out"; "input" = "copyOR:In"; }
                        ];
                        "inputs"  = [ "copyIL:In" ];
                        "outputs" = [ "copyOL:Out" "copyOR:Out" ];
                    };
                    "capture.props" = {
                        "node.name" = "capture.UM2_Mic";
                        "audio.position" = [ "AUX0" ];
                        "stream.dont-remix" = true;
                        "target.object" = "alsa_input.usb-Burr-Brown_from_TI_USB_Audio_CODEC-00.pro-input-0";
                        "node.passive" = true;
                    };
                    "playback.props" = {
                        "node.name" = "UM2_Mic";
                        "media.class" = "Audio/Source";
                        "media.role" = "Communication";
                        "audio.position" = [ "FL" "FR" ];
                    };
                };
            }
            {   "name" = "libpipewire-module-loopback";
                "args" = {
                    "node.description" = "UM2 INST2";
                    "media.name" = "UM2 INST2";
                    "capture.props" = {
                        "node.name" = "capture.UM2_INST2";
                        "audio.position" = [ "AUX1" ];
                        "stream.dont-remix" = true;
                        "target.object" = "alsa_input.usb-Burr-Brown_from_TI_USB_Audio_CODEC-00.pro-input-0";
                        "node.passive" = true;
                    };
                    "playback.props" = {
                        "node.name" = "UM2_INST2";
                        "media.class" = "Audio/Source";
                        "audio.position" = [ "MONO" ];
                    };
                };
            }
        ];
      };
    })
  ];

}