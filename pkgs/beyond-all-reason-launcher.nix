{ fetchurl
, appimageTools
}:
let
  pname = "byar";
  version = "1.2988.0";
in
appimageTools.wrapType2 {
  name = "${pname}-${version}";

  src = fetchurl {
    url = "https://github.com/beyond-all-reason/BYAR-Chobby/releases/download/v${version}/Beyond-All-Reason-${version}.AppImage";
    hash = "sha256-ZJW5BdxxqyrM2TJTO0SBp4BXt3ILyi77EZx73X8hqJE=";
  };

  extraPkgs = pkgs: [ pkgs.openal ];

  meta = {
    mainProgram = "${pname}-${version}";
    description = "Beyond All Reason";
    homepage = "https://www.beyondallreason.info";
    platforms = [ "x86_64-linux" ];
    downloadPage = "https://www.beyondallreason.info/download";
  };
}
