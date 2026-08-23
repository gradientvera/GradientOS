{
  stdenvNoCC,
  lib,
  jetbrains,
  steam-run,
}:

stdenvNoCC.mkDerivation {
  pname = "jetbrains-rider-steam-run-desktop";
  version = jetbrains.rider.version;

  dontUnpack = true;

  installPhase = ''
    mkdir -p $out/share/applications
    cp ${jetbrains.rider}/share/applications/rider.desktop \
       $out/share/applications/rider-steam-run.desktop

    substituteInPlace $out/share/applications/rider-steam-run.desktop \
      --replace-fail \
        "Exec=rider" \
        "Exec=${lib.getExe steam-run} ${lib.getExe jetbrains.rider}" \
      --replace-fail \
        "Name=Rider" \
        "Name=Rider (steam-run)"
  '';
}
