{ fetchFromGitHub
, home-assistant
, buildHomeAssistantComponent
}:
let
  owner = "uvejota";
  version = "2024.07.6";
  pythonPkgs = home-assistant.python.pkgs;
in buildHomeAssistantComponent {
  inherit version owner;
  domain = "edata";
  src = fetchFromGitHub {
    inherit owner;
    repo = "homeassistant-edata";
    rev = version;
    hash = "sha256-HGCjwYf5aLFUMuh4InAjLZHHIU6aidjoAQuhH9W+pkw=";
  };

  propagatedBuildInputs = [
    pythonPkgs.python-dateutil
    # This derivation is ONLY used for this integration, so just keep it here
    (let
      pname = "e-data";
      version = "1.2.22";
    in pythonPkgs.buildPythonPackage {
      inherit pname version;
      pyproject = true;
      src = fetchFromGitHub {
        inherit owner;
        repo = "python-edata";
        rev = "v${version}";
        hash = "sha256-h7nqrFKsh97GIebGeIC5E1m1BROTu8ZZ1TrDSO4nFWk=";
      };

      build-system = [
        pythonPkgs.setuptools
      ];

      dependencies = with pythonPkgs; [
        dateparser
        freezegun
        holidays
        pytest
        python-dateutil
        requests
        voluptuous
        jinja2
      ];
    })
  ];
}