# Can't get it to compile and I can't be arsed to fix it
# so downloading the release it is...
{ stdenv
, fetchurl
}:
stdenv.mkDerivation rec {
  pname = "xiaomi-vacuum-map-card";
  version = "2.3.1";

  src = fetchurl {
    url = "https://github.com/PiotrMachowski/lovelace-xiaomi-vacuum-map-card/releases/download/v${version}/xiaomi-vacuum-map-card.js";
    sha256 = "sha256-d2O9G20BARHzQ35es4SmSnyWxgxTM2gEALwQfm0GTX8=";
  };

  dontBuild = true;
  dontUnpack = true;
  dontPatch = true;

  installPhase = ''
    mkdir -p $out
    cp $src $out/xiaomi-vacuum-map-card.js
  '';

  passthru.entrypoint = "xiaomi-vacuum-map-card.js";

}