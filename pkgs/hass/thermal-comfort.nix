{ fetchFromGitHub
, buildHomeAssistantComponent
}:
let
  owner = "dolezsa";
  version = "2.2.5";
in buildHomeAssistantComponent {
  inherit version owner;
  domain = "thermal_comfort";

  src = fetchFromGitHub {
    inherit owner;
    repo = "thermal_comfort";
    rev = version;
    hash = "sha256-1T8HQmsbtMlt/85xTj4qaK0yAV0Z6C98q5TeR2/dDBg=";
  };

}