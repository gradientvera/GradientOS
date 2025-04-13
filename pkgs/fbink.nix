{   lib
  , stdenv
  , fetchFromGitHub

  # One of "KOBO", "LINUX", "KINDLE",
  # "KINDLE_LEGACY", "CERVANTES", "REMARKABLE",
  # or "POCKETBOOK"
  , device ? "KOBO"

  , MINIMAL ? false

  # The below options are only useful when MINIMAL = true
  , DRAW ? !MINIMAL
  , BITMAP ? !MINIMAL
  , FONTS ? !MINIMAL
  , IMAGE ? !MINIMAL
  , OPENTYPE ? !MINIMAL
  , INPUT ? !MINIMAL
  , BUTTON_SCAN ? !MINIMAL
  , UNIFONT ? !MINIMAL
}:
let
  repo = "FBInk";
  rev = "94df13530be8bee12fa5af210ddfe0cf1223cdb3";
  date = "2025-04-07";
in
stdenv.mkDerivation {

  makeFlags = [
    # Device support
    "${device}=1"
  ] ++ (if device == "kindle_legacy" then [ "LEGACY=1" ] else [])
    ++ (if MINIMAL then [ "MINIMAL=1" ] else [])
    ++ (if DRAW then [ "DRAW=1" ] else [])
    ++ (if BITMAP then [ "BITMAP=1" ] else [])
    ++ (if FONTS then [ "FONTS=1" ] else [])
    ++ (if IMAGE then [ "IMAGE=1" ] else [])
    ++ (if OPENTYPE then [ "OPENTYPE=1" ] else [])
    ++ (if INPUT then [ "INPUT=1" ] else [])
    ++ (if BUTTON_SCAN then [ "BUTTON_SCAN=1" ] else [])
    ++ (if UNIFONT then [ "UNIFONT=1" ] else []);

  name = "${repo}-git-unstable-${date}";
  
  enableParallelBuilding = true;

  src = fetchFromGitHub {
    inherit repo rev;
    owner = "NiLuJe";
    hash = "sha256-Z53Rqukyn1HTygGPU/YtNT6m1opG7wpc/tSFaBQwBh0=";
    fetchSubmodules = true;
  };

  buildPhase = ''
    make static
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp ./Release/fbink $out/bin/
  '';

  # This is not meant to be ran on NixOS, thus...
  dontFixup = true;
  dontDisableStatic = true;

  meta = {
    mainProgram = "fbink";
    description = "FrameBuffer eInker, a small tool & library to print text & images to an eInk Linux framebuffer";
    homepage = "https://github.com/NiLuJe/FBInk";
    downloadPage = "https://github.com/NiLuJe/FBInk/releases";
    license = lib.licenses.gpl3;
  };

}