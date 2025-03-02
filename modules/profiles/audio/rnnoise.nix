{ config, lib, pkgs, ... }:
let
  cfg = config.gradient;
in
{
  options = {
    gradient.profiles.audio.rnnoise.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Whether to enable a Noise Cancelling Source.
        Requires the audio profile to be enabled.
      '';
    };
  };

  config = lib.mkMerge [
    (lib.mkIf (cfg.profiles.audio.enable && cfg.profiles.audio.rnnoise.enable) {
      services.pipewire.extraConfig.pipewire."00-rnnoise.conf" = {
        "context.modules" = [
        {   "name" = "libpipewire-module-filter-chain";
            "args" = {
                "node.description" =  "Noise Canceling source";
                "media.name" =  "Noise Canceling source";
                "filter.graph" = {
                    "nodes" = [
                        {
                            "type" = "ladspa";
                            "name" = "rnnoise";
                            "plugin" = "${pkgs.rnnoise-plugin}/lib/ladspa/librnnoise_ladspa.so";
                            "label" = "noise_suppressor_stereo";
                            "control" = {
                                "VAD Threshold (%)" = 50.0;
                                "VAD Grace Period (ms)" = 1000;
                                "Retroactive VAD Grace (ms)" = 100;
                            };
                        }
                    ];
                };
                "audio.position" = [ "FL" "FR" ];
                "capture.props" = {
                    "node.name" =  "capture.rnnoise_source";
                    "node.passive" = true;
                    "audio.rate" = 48000;
                };
                "playback.props" = {
                    "node.name" =  "rnnoise_source";
                    "media.class" = "Audio/Source";
                    "media.role" = "Communication";
                    "audio.rate" = 48000;
                };
            };
        }
        ];
      };
    })
  ];

}