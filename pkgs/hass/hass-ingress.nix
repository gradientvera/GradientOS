{ fetchFromGitHub
, home-assistant
, buildHomeAssistantComponent
}:
let
  owner = "lovelylain";
  version = "1.2.8";
  pythonPkgs = home-assistant.python.pkgs;
in buildHomeAssistantComponent {
  inherit version owner;
  domain = "ingress";

  src = fetchFromGitHub {
    inherit owner;
    repo = "hass_ingress";
    rev = version;
    hash = "sha256-Bzh6aTo/0KflUwZUoZLJcjk1tCWY4oC3hG0U2mHfqOw=";
  };

}