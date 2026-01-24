{ fetchFromGitHub
, home-assistant
, buildHomeAssistantComponent
}:
let
  owner = "BSkando";
  repo = "GoogleFindMy-HA";
  version = "V1.7.0-3";
  pythonPkgs = home-assistant.python.pkgs;
in buildHomeAssistantComponent {
  inherit version owner;
  domain = "googlefindmy";

  src = fetchFromGitHub {
    inherit owner repo;
    rev = version;
    hash = "sha256-uf7XRGAj1kehCQQTHn9Z8qSldqSMHwmo7iODZWLvUhc=";
  };

  propagatedBuildInputs = with pythonPkgs; [
    gpsoauth
    beautifulsoup4
    pyscrypt
    cryptography
    pycryptodomex
    ecdsa
    pytz
    protobuf
    httpx
    h2
    setuptools
    aiohttp
    grpclib
    http-ece
    requests
    undetected-chromedriver
    selenium
  ];
}