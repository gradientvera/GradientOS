{ lib
, SDL2
, cmake
, stdenv
, fetchFromGitHub
}:
let 
    repo = "FNA3D";
    rev = "24.05";
in
stdenv.mkDerivation {
    name = "${repo}-${rev}";
    nativeBuildInputs = [ cmake ];
    buildInputs = [ SDL2 ];
    src = fetchFromGitHub {
        inherit repo rev;
        owner = "FNA-XNA";
        hash = "sha256-elDnNYrAIfz0HDFGK5ruLhRN3FboaBSOAnNXOdX3F7E=";
        fetchSubmodules = true;
    };
    installPhase = ''
        mkdir -p $out/lib
        cp libFNA3D.so $out/lib/libFNA3D.so.0
    '';
}