{ runCommand, steam }:

runCommand "steam-deck-client" { } ''
  mkdir -p $out/share/applications
  cp ${steam}/share/applications/steam.desktop $out/share/applications/steam-deck-client.desktop
  substituteInPlace $out/share/applications/steam-deck-client.desktop \
    --replace "Name=Steam" "Name=Steam (Deck Client)" \
    --replace "Exec=steam" "Exec=steam -steamdeck"
''