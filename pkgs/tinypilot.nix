{ python3, fetchFromGitHub, ... }:
let
  version = "1.9.0";
in python3.pkgs.buildPythonApplication {
  inherit version;
  pname = "tinypilot";
  format = "setuptools";
  
  doCheck = false;

  src = fetchFromGitHub {
    owner = "tiny-pilot";
    repo = "tinypilot";
    hash = "sha256-t7k5M6OCRzcIJYz0iG8Mye7bqPp0nQ+qccsoACU6UHs=";
    rev = version;
  };

  propagatedBuildInputs = with python3.pkgs; [
    eventlet
    flask
    flask-socketio
    flask-wtf
    pyyaml
  ];

}