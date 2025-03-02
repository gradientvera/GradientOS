{ config, lib, pkgs, ... }:
let
  cfg = config.gradient;
in
{
  imports = [
    ./um2.nix
    ./rnnoise.nix
    ./virtual-sink.nix
    ./input-normalizer.nix
  ];

  options = {
    gradient.profiles.audio.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Whether to enable the GradientOS audio profile.
        Enables Pipewire, and adds ALSA, JACK and PulseAudio support for it.
      '';
    };
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.profiles.audio.enable {
      services.pulseaudio.enable = lib.mkForce false;
    
      services.pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
        jack.enable = true;
        wireplumber.enable = true;
      };

      environment.systemPackages = with pkgs; [
        jack-matchmaker
        qpwgraph
      ];

      # Very permissive limits... But it fixes a race condition!
      systemd.services.wireplumber = {
        startLimitBurst = 100;
        startLimitIntervalSec = 60;
      };
      systemd.user.services.wireplumber = {
        startLimitBurst = 100;
        startLimitIntervalSec = 60;
      };
    })
  ];

}