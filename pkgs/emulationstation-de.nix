{ fetchurl
, appimageTools
}:
let
  pname = "es-de";
  version = "3.4.0";
  src = fetchurl {
    url = "https://gitlab.com/es-de/emulationstation-de/-/package_files/246875981/download";
    hash = "sha256-TLZs/JIwmXEc+g7d2D22R0SmKU4C4//Rnuhn93qI7H4=";
  };
  appimageContents = appimageTools.extract {
    inherit pname version src;
    # Allow loading libretro cores from NixOS paths
    postExtract = ''
      substituteInPlace $out/usr/share/es-de/resources/systems/linux/es_find_rules.xml \
        --replace-fail \
        '<entry>/usr/lib/libretro</entry>' \
        '<entry>/usr/lib/libretro</entry>\n<!-- NixOS Paths -->\n<entry>/run/current-system/sw/lib/retroarch/cores</entry>\n<entry>~/.nix-profile/lib/retroarch/cores</entry>'
    '';
  };
in
appimageTools.wrapAppImage {
  inherit pname version;
  
  src = appimageContents;

  extraInstallCommands = ''
    mkdir -p $out/share/icons
    install -m 444 -D ${appimageContents}/org.es_de.frontend.desktop $out/share/applications/org.es_de.frontend.desktop
    install -m 444 -D ${appimageContents}/usr/share/pixmaps/org.es_de.frontend.svg $out/share/pixmaps/org.es_de.frontend.svg
    install -m 444 -D ${appimageContents}/usr/share/icons/hicolor/scalable/apps/org.es_de.frontend.svg $out/share/icons/hicolor/scalable/apps/org.es_de.frontend.svg
    install -m 444 -D ${appimageContents}/usr/share/icons/hicolor/scalable/apps/org.es_de.frontend.svg $out/share/icons/hicolor/scalable/apps/org.es_de.frontend.svg
  '';

  extraBwrapArgs = [
    # Do not create an "ES-DE" folder on my home folder! Put it somewhere appropriate sheesh.
    "--setenv ESDE_APPDATA_DIR ~/.local/share/ES-DE"
  ];

  meta = {
    mainProgram = pname;
    description = "EmulationStation DE";
    homepage = "https://es-de.org/";
    platforms = [ "x86_64-linux" ];
    downloadPage = "https://es-de.org/#Download";
  };
}
