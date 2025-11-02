# Official integration has been merged
{ fetchFromGitHub
, home-assistant
, buildHomeAssistantComponent
}:
let
  owner = "openrgb-ha";
  version = "2.7.2";
  pythonPkgs = home-assistant.python.pkgs;
in buildHomeAssistantComponent {
  inherit version owner;
  domain = "openrgb";

  src = fetchFromGitHub {
    inherit owner;
    repo = "openrgb-ha";
    rev = "v${version}";
    hash = "sha256-CABmizTZM3kbEaUyi7Ni/ONIiewU4NAF/wZCzz+DjOw=";
  };

  propagatedBuildInputs = [
    pythonPkgs.openrgb-python
  ];
}