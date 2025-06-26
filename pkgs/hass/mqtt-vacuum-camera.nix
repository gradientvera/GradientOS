{ fetchFromGitHub
, home-assistant
, buildHomeAssistantComponent
}:
let
  owner = "sca075";
  version = "2025.06.0b0";
  pythonPkgs = home-assistant.python.pkgs;
in buildHomeAssistantComponent {
  inherit version owner;
  domain = "mqtt_vacuum_camera";

  src = fetchFromGitHub {
    inherit owner;
    repo = "mqtt_vacuum_camera";
    rev = version;
    hash = "sha256-PeeIMwxta1rb78JIgTFKwFzIc8J4FpFoNRq48oSX3t0=";
  };

  propagatedBuildInputs = [
    # This derivation is ONLY used for this integration, so just keep it here
    (let
      pname = "valetudo-map-parser";
      version = "0.1.9a8";
    in pythonPkgs.buildPythonPackage {
      inherit pname version;

      src = fetchFromGitHub {
        inherit owner;
        repo = "Python-package-valetudo-map-parser";
        rev = "v${version}";
        hash = "sha256-DvKaY2r++REdpibRwCaYGMOyq19cCgz2l2ubbI333Ug=";
      };

      pyproject = true;

      build-system = [
        pythonPkgs.poetry-core
      ];

      dependencies = with pythonPkgs; [
        pillow
        numpy
        scipy
      ];
    })
  ];
}