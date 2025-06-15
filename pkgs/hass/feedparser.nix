{ fetchFromGitHub
, home-assistant
, buildHomeAssistantComponent
}:
let
  owner = "custom-components";
  version = "0.1.12";
  pythonPkgs = home-assistant.python.pkgs;
in buildHomeAssistantComponent {
  inherit version owner;
  domain = "feedparser";

  src = fetchFromGitHub {
    inherit owner;
    repo = "feedparser";
    rev = version;
    hash = "sha256-LYNTnp8GgPSxiretr12QNrylTVWNArZORdKRL8P6vfA=";
  };

  propagatedBuildInputs = with pythonPkgs; [
    python-dateutil
    requests-file
    feedparser
    requests
  ];
}