{ config, ports, ... }:
{

  # Too lazy to package this at the moment lol
  virtualisation.oci-containers.containers.linux-voice-assistant = {
    image = "ghcr.io/ohf-voice/linux-voice-assistant:nightly";
    ports = [ ];
    volumes = [
      "/run/user/1000:/run/user/1000"
      "/home/vera/.wakewords:/app/wakewords/custom"
      "/home/vera/.linux-voice-assistant/wakeword-data:/app/local"
      "/home/vera/.linux-voice-assistant/configuration:/app/configuration"
      "/home/vera/.linux-voice-assistant/sounds-custom:/app/sounds/custom"
      
    ];
    environment = {
      TZ = config.time.timeZone;
      LVA_USER_ID = "1000";
      LVA_USER_GROUP = "1000";
      LVA_PULSE_SERVER = "/run/user/1000/pulse/native";
      LVA_XDG_RUNTIME_DIR = "/run/user/1000";
      WAKE_WORD_DIR = "/app/wakewords/custom/openWakeWord";
      XDG_RUNTIME_DIR = "/run/user/1000";
      PULSE_SERVER = "/run/user/1000/pulse/native";
      PORT = toString ports.linux-voice-assistant;
      CLIENT_NAME = config.networking.hostName;
    };
    networks = [ "host" ];
    podman.user = "vera";
    capabilities.SYS_NICE = true;
    extraOptions = [
      "--group-add" "audio"
    ];
  };

  systemd.user.tmpfiles.users.vera.rules = [
    "d /home/vera/.wakewords 0755 vera users - -"
    "d /home/vera/.linux-voice-assistant 0755 vera users - -"
    "d /home/vera/.linux-voice-assistant/wakeword-data 0755 vera users - -"
    "d /home/vera/.linux-voice-assistant/configuration 0755 vera users - -"
    "d /home/vera/.linux-voice-assistant/sounds-custom 0755 vera users - -"
  ];

  networking.firewall.allowedTCPPorts = [
    ports.linux-voice-assistant
  ];
  networking.firewall.allowedUDPPorts = [
    ports.linux-voice-assistant
  ];

}