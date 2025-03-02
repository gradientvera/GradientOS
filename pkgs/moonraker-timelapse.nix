{ lib
, wget
, stdenvNoCC
, fetchFromGitHub
}:
let
  name = "moonraker-timelapse";
  revision = "c7fff11e542b95e0e15b8bb1443cea8159ac0274";
in
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = name;
  version = revision;

  dontBuild = true;
  installPhase = ''
    mkdir -p $out/lib/${name}
    cp -r ./* $out/lib/${name}/
  '';

  src = fetchFromGitHub {
    owner = "mainsail-crew";
    repo = name;
    rev = revision;
    sha256 = "sha256-ZYSeSn3OTManyTbNOnCfhormjFMgomNk3VXOVqBr9zg=";
  };

  passthru.moonrakerOverrideAttrs = let
    pkg = finalAttrs.finalPackage;
  in
    (prevAttrs: {
      installPhase = (prevAttrs.installPhase or "") + ''
        cp ${pkg}/lib/${name}/component/timelapse.py $out/lib/moonraker/components/timelapse.py
        substituteInPlace $out/lib/moonraker/components/timelapse.py \
          --replace-fail '"wget "' '"${wget}/bin/wget "'
      '';
    });  

  passthru.macroFile = "${finalAttrs.finalPackage}/lib/${name}/klipper_macro/timelapse.cfg";
})