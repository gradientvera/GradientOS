{ config, ports, ... }:
{

  services.wyoming = {
    piper.servers.english = {
      enable = true;
      voice = "en_GB-cori-medium";
      uri = "tcp://0.0.0.0:${toString ports.piper-english}";
      zeroconf.enable = true;
    };

    piper.servers.spanish = {
      enable = true;
      speaker = 1;
      voice = "es_ES-sharvard-medium";
      uri = "tcp://0.0.0.0:${toString ports.piper-spanish}";
      zeroconf.enable = true;
    };
    
    faster-whisper.servers.english = {
      enable = true;
      language = "en";
      model = "small-int8";
      zeroconf.enable = true;
      uri = "tcp://0.0.0.0:${toString ports.whisper-english}";
    };

    faster-whisper.servers.spanish = {
      enable = true;
      language = "es";
      model = "small-int8";
      zeroconf.enable = true;
      uri = "tcp://0.0.0.0:${toString ports.whisper-spanish}";
    };

    openwakeword = {
      enable = true;
      uri = "tcp://0.0.0.0:${toString ports.openwakeword}";
      customModelsDirectories = [
        "/home/vera/.wakewords/openWakeWord"
        "/data/openwakeword"
      ];
    };
  };

  # Same as the threads in a single CPU on asiyah
  systemd.services.wyoming-faster-whisper-english.environment.OMP_NUM_THREADS = "36";
  systemd.services.wyoming-faster-whisper-spanish.environment.OMP_NUM_THREADS = "36";

  systemd.tmpfiles.settings."10-openwakeword"."/data/openwakeword".d = {
    mode = "0777";
  };

}