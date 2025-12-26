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
        audio.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
        jack.enable = true;
        wireplumber.enable = true;
      };

      services.udev.extraRules = ''
        DEVPATH=="/devices/virtual/misc/cpu_dma_latency", OWNER="root", GROUP="audio", MODE="0660"
      '';

      security.pam.loginLimits =
        let
          mkLimit = item: value: {
            inherit item value;
            domain = "@pipewire";
            type = "-";
          };
        in
      [
        # As per https://gitlab.freedesktop.org/pipewire/pipewire/-/wikis/Performance-tuning#rlimits
        (mkLimit "rtprio" "95")
        (mkLimit "nice" "-19")
        (mkLimit "memlock" "4194304")
        {
          domain = "@audio";
          type = "-";
          item = "rtprio";
          value = "99";
        }
      ];

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

    (lib.mkIf config.system76-scheduler.enable {
      services.system76-scheduler.settings.processScheduler.pipewireBoost.profile = {
        nice = -19;
        ioClass = "realtime";
      };
    })
  ];

}