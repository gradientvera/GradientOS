{ config, lib, pkgs, ... }:
let
  cfg = config.gradient;
in
{
  options = {
    gradient.profiles.audio.umc202hd.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Whether to enable support for the UMC202HD USB audio card.
        Requires the audio profile to be enabled.
      '';
    };
  };

  config = lib.mkMerge [
    (lib.mkIf (cfg.profiles.audio.enable && cfg.profiles.audio.umc202hd.enable) {
      services.pipewire.extraConfig.pipewire."10-umc202hd.conf" = {
        "context.modules" = [
            {   "name" = "libpipewire-module-filter-chain";
                "args" = {
                    "node.description" = "UMC202HD Combined Microphone";
                    "media.name" = "UMC202HD Combined Microphone";
                    "filter.graph" = {
                        "nodes" = [
                            {
                                "name"    = "mixer";
                                "type"    = "builtin";
                                "label"   = "mixer";
                                "control" = { "Gain 1" = 0.5; "Gain 2" = 0.5; };
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
                            { "output" = "mixer:Out"; "input" = "copyOL:In"; }
                            { "output" = "mixer:Out"; "input" = "copyOR:In"; }
                        ];
                        "inputs"  = [ "mixer:In 1" "mixer:In 2" ];
                        "outputs" = [ "copyOL:Out" "copyOR:Out" ];
                    };
                    "capture.props" = {
                        "node.name" = "capture.UMC202HD_Combined";
                        "audio.channels" = 2;
                        "audio.position" = [ "AUX0" "AUX1" ];
                        "stream.dont-remix" = true;
                        "target.object" = "alsa_input.usb-BEHRINGER_UMC202HD_192k_12345678-00.pro-input-0";
                        "node.passive" = true;
                    };
                    "playback.props" = {
                        "node.name" = "UMC202HD_Combined";
                        "media.class" = "Audio/Source";
                        "media.role" = "Communication";
                        "audio.channels" = 2;
                        "audio.position" = [ "FL" "FR" ];
                    };
                };
            }
            {   "name" = "libpipewire-module-filter-chain";
                "args" = {
                    "node.description" = "UMC202HD Left Microphone";
                    "media.name" = "UMC202HD Left Microphone";
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
                        "node.name" = "capture.UMC202HD_Left";
                        "audio.position" = [ "AUX0" ];
                        "stream.dont-remix" = true;
                        "target.object" = "alsa_input.usb-BEHRINGER_UMC202HD_192k_12345678-00.pro-input-0";
                        "node.passive" = true;
                    };
                    "playback.props" = {
                        "node.name" = "UMC202HD_Left";
                        "media.class" = "Audio/Source";
                        "media.role" = "Communication";
                        "audio.channels" = 2;
                        "audio.position" = [ "FL" "FR" ];
                    };
                };
            }
            {   "name" = "libpipewire-module-filter-chain";
                "args" = {
                    "node.description" = "UMC202HD Right Microphone";
                    "media.name" = "UMC202HD Right Microphone";
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
                        "node.name" = "capture.UMC202HD_Right";
                        "audio.position" = [ "AUX1" ];
                        "stream.dont-remix" = true;
                        "target.object" = "alsa_input.usb-BEHRINGER_UMC202HD_192k_12345678-00.pro-input-0";
                        "node.passive" = true;
                    };
                    "playback.props" = {
                        "node.name" = "UMC202HD_Right";
                        "media.class" = "Audio/Source";
                        "media.role" = "Communication";
                        "audio.channels" = 2;
                        "audio.position" = [ "FL" "FR" ];
                    };
                };
            }
        ];
      };
    })
  ];

}