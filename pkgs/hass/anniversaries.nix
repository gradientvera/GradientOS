{ fetchFromGitHub
, home-assistant
, buildHomeAssistantComponent
}:
let
  owner = "pinkywafer";
  version = "6.0.1";
  pythonPkgs = home-assistant.python.pkgs;
in buildHomeAssistantComponent {
  inherit version owner;
  domain = "anniversaries";

  src = fetchFromGitHub {
    inherit owner;
    repo = "Anniversaries";
    rev = version;
    hash = "sha256-9r5Uez7TdJsgoBQcVqUX36hPO2VWqzWk3+EV3VyqGwY=";
  };

  propagatedBuildInputs = with pythonPkgs; [
    python-dateutil
    voluptuous
    (let
      owner = "ludeeus";
      pname = "integrationhelper";
      version = "0.2.2";
    in pythonPkgs.buildPythonPackage {
      inherit pname version;

      src = pkgs.fetchFromGitHub {
        inherit owner;
        repo = "integrationhelper";
        rev = version;
        hash = "sha256-Eoa3rRa3SssVNItFEK/67JAkcio22z0ACYRmv2fRDtg=";
      };

      build-system = [
        pkgs.python313Packages.setuptools
      ];

      dependencies = with pkgs.python313Packages; [
        aiohttp
        async-timeout
        backoff
      ];
    })
  ];
}