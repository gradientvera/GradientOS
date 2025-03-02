{ config, lib, pkgs, ... }:
let
  cfg = config.gradient;
in
{
  options = {
    gradient.profiles.audio.input-normalizer.enable = lib.mkOption {
      type = lib.types.bool;
      default = cfg.profiles.audio.enable;
      description = ''
        Whether to enable a Normalizer Source. Enabled by default when the audio profile is enabled.
        Requires the audio profile to be enabled.
      '';
    };
  };

  config = lib.mkMerge [
    (lib.mkIf (cfg.profiles.audio.enable && cfg.profiles.audio.input-normalizer.enable) {
      services.pipewire.extraConfig.pipewire."00-normalizer.conf" = {
        "context.modules" = [
        {   "name" = "libpipewire-module-filter-chain";
            "args" = {
                "node.description" =  "Normalizer source";
                "media.name" =  "Normalizer source";
                "filter.graph" = {
                    "nodes" = [
                        {
                            "type" = "ladspa";
                            "name" = "compressor";
                            "plugin" = "${pkgs.ladspaPlugins}/lib/ladspa/sc4_1882.so";
                            "label" = "sc4";
                            "control" = {
                                "RMS/peak" = 0.0;
                                "Attack time (ms)" = 60;
                                "Release time (ms)" = 600;
                                "Threshold level (dB)" = -5;
                                "Ratio (1:n)" = 15;
                                "Knee radius (dB)" = 2;
                                "Makeup gain (dB)" = 4;
                            };
                        }
                        {
                            "type" = "ladspa";
                            "name" = "limiter";
                            "plugin" = "${pkgs.ladspaPlugins}/lib/ladspa/fast_lookahead_limiter_1913.so";
                            "label" = "fastLookaheadLimiter";
                            "control" = {
                                "Input gain (dB)" = 0;
                                "Limit (dB)" = -20;
                                "Release time (s)" = 0.8;
                            };
                        }
                    ];
                    "links" = [
                        { "output" = "compressor:Left output"; "input" = "limiter:Input 1"; }
                        { "output" = "compressor:Right output"; "input" = "limiter:Input 2"; }
                    ];
                    "inputs"  = [ "compressor:Left input" "compressor:Right input" ];
                    "outputs" = [ "limiter:Output 1" "limiter:Output 2" ];
                };
                "audio.position" = [ "FL" "FR" ];
                "capture.props" = {
                    "node.name" =  "capture.normalizer_source";
                    "node.passive" = true;
                    "audio.rate" = 48000;
                };
                "playback.props" = {
                    "node.name" =  "normalizer_source";
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