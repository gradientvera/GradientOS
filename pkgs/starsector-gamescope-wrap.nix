{ starsector
, makeDesktopItem
, gamescope
, ...
}:
starsector.overrideAttrs (final: prev: {
  desktopItems = [
    (makeDesktopItem {
      name = "starsector";
      exec = "sh -c \"${gamescope}/bin/gamescope -W 1920 -H 1080 -- starsector\"";
      icon = "starsector";
      comment = final.meta.description;
      genericName = "starsector";
      desktopName = "Starsector";
      categories = [ "Game" ];
    })
  ];
})