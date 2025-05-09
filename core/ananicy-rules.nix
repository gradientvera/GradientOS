[
  # Using cachyos types, see: https://github.com/CachyOS/ananicy-rules/blob/master/00-types.types
  { name = "colmena"; type = "BG_CPUIO"; }
  { name = "ustreamer"; type = "Player-Video"; }
  { name = "jellyfin"; type = "Player-Video"; }
  { name = "ffmpeg"; type = "Heavy_CPU"; }
  { name = "tdarr-ffmpeg"; type = "Heavy_CPU"; }

  # Set VR relevant programs to low-latency
  { name = "wivrn-server"; type = "LowLatency_RT"; }
  { name = "wivrn-dashboard"; type = "LowLatency_RT"; }
  { name = "alvr-dashboard"; type = "LowLatency_RT"; }
  { name = "vrserver"; type = "LowLatency_RT"; }
  { name = "vrstartup"; type = "LowLatency_RT"; }
  { name = "vrmonitor"; type = "LowLatency_RT"; }
  { name = "vrcompositor"; type = "LowLatency_RT"; }
]