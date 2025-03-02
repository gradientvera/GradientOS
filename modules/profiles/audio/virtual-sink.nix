{ config, lib, pkgs, ... }:
let
  cfg = config.gradient;
in
{
  options = {
    gradient.profiles.audio.virtual-sink.enable = lib.mkOption {
      type = lib.types.bool;
      default = cfg.profiles.audio.enable;
      description = ''
        Whether to enable a Virtual Sink. Enabled by default when the audio profile is enabled.
        Requires the audio profile to be enabled.
      '';
    };
  };

  config = lib.mkMerge [
    (lib.mkIf (cfg.profiles.audio.enable && cfg.profiles.audio.virtual-sink.enable) {
      services.pipewire.extraConfig.pipewire."99-virtual-sink.conf" = {
        "context.modules" = [
            {   "name" = "libpipewire-module-loopback";
                "args" = {
                    "node.description" = "Virtual Sink";
                    "media.name" = "Virtual Sink";
                    "capture.props" = {
                        "node.name" = "capture.virtual_sink";
                        "audio.position" = [ "FL" "FR" ];
                        "media.class" = "Audio/Sink";
                    };
                    "playback.props" = {
                        "node.name" = "output.virtual_sink";
                        "audio.position" = [ "FL" "FR" ];
                        "stream.dont-remix" = true;
                        "node.passive" = true;
                        "media.class" = "Audio/Source";
                        "media.role" = "Communication";
                    };
                };
            }
        ];
      };
    })
  ];

}