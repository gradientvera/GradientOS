{ fetchFromGitHub
, home-assistant
, buildHomeAssistantComponent
}:
let
  owner = "openrgb-ha";
  version = "2.7.0";
  pythonPkgs = home-assistant.python.pkgs;
in buildHomeAssistantComponent {
  inherit version owner;
  domain = "openrgb";

  src = fetchFromGitHub {
    inherit owner;
    repo = "openrgb-ha";
    rev = "v${version}";
    hash = "sha256-cTOkTyOU3aBXIGU1FL1boKU/6RIeFMC8yKc+0wcTVUU=";
  };

  propagatedBuildInputs = [
    pythonPkgs.openrgb-python
  ];
}