{ fetchFromGitHub
, home-assistant
, buildHomeAssistantComponent
}:
let
  owner = "custom-components";
  version = "0.4.4";
  pythonPkgs = home-assistant.python.pkgs;
in buildHomeAssistantComponent {
  inherit version owner;
  domain = "sonarr_upcoming_media";

  src = fetchFromGitHub {
    inherit owner;
    repo = "sensor.sonarr_upcoming_media";
    rev = version;
    hash = "sha256-O22C3Cw2fXONDvdwt3Wb58EOuwKvA/F0vW6syq6mRaY=";
  };

}