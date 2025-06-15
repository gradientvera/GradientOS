{ fetchFromGitHub
, buildHomeAssistantComponent
}:
let
  owner = "custom-components";
  version = "0.4.2";
in buildHomeAssistantComponent {
  inherit version owner;
  domain = "radarr_upcoming_media";

  src = fetchFromGitHub {
    inherit owner;
    repo = "sensor.radarr_upcoming_media";
    rev = version;
    hash = "sha256-3YdqPR7ctmW2v1trl4akgH4oRObgTmfYxF7ZMdN9Tpg=";
  };

}