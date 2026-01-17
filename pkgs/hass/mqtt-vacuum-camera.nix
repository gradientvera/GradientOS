{ fetchFromGitHub
, fetchPypi
, home-assistant
, buildHomeAssistantComponent
}:
let
  owner = "sca075";
  version = "2025.11.0";
  pythonPkgs = home-assistant.python.pkgs;
  # These two derivations are ONLY used for this integration, so just keep it here
  mvcrender = (
    let
      pname = "mvcrender";
      version = "0.0.6";
    in
    pythonPkgs.buildPythonPackage {
      inherit pname version;

      src = fetchPypi {
        inherit version;
        pname = "mvcrender";
        hash = "sha256-z+FYsvMaSuEs6id0c6nLlYwjpCqhyA3dQphBwR4LdfA=";
      };

      pyproject = true;

      build-system = [
        pythonPkgs.setuptools
      ];

      dependencies = with pythonPkgs; [
        numpy
      ];
    }
  );
  valetudo-map-parser = (
    let
      pname = "valetudo-map-parser";
      version = "0.1.12";
    in
    pythonPkgs.buildPythonPackage {
      inherit pname version;

      src = fetchPypi {
        inherit version;
        pname = "valetudo_map_parser"; # name mismatch
        hash = "sha256-eGTGlcz0mqZac+kMT+fICKNE84AM5R5PSEcboMq4LgY=";
      };

      pyproject = true;

      build-system = [
        pythonPkgs.poetry-core
      ];

      dependencies = with pythonPkgs; [
        numpy
        pillow
        scipy
      ];

      propagatedBuildInputs = [
        mvcrender
      ];
    }
  );
in buildHomeAssistantComponent {
  inherit version owner;
  domain = "mqtt_vacuum_camera";

  src = fetchFromGitHub {
    inherit owner;
    repo = "mqtt_vacuum_camera";
    rev = version;
    hash = "sha256-wN+xbIv2y902lXZ1QnywvAkgh7GC2zdWaanmpZplfLA=";
  };

  propagatedBuildInputs = [
    valetudo-map-parser
  ];
}