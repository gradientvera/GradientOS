{ lib, python3, pipewire }:

python3.pkgs.buildPythonApplication rec {
  pname = "jack-matchmaker";
  version = "0.10.0";
  src = python3.pkgs.fetchPypi {
    inherit pname version;
    sha256 = "70b8f53b0c75e8351ccdad4bf37bee8b544643604e0db1938ed749a4c0fa6ba6";
  };
  makeWrapperArgs = ["--prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [ pipewire.jack ]}"];
  doCheck = false;
}