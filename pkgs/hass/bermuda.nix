{ fetchFromGitHub
, home-assistant
, buildHomeAssistantComponent
}:
let
  owner = "agittins";
  version = "0.8.4";
in buildHomeAssistantComponent {
  inherit version owner;
  domain = "bermuda";

  src = fetchFromGitHub {
    inherit owner;
    repo = "bermuda";
    rev = "v${version}";
    hash = "sha256-xshVYsFJKxfTBIFFDE5fx3fX2CilTVBV0+azUbxjv0c=";
  };

  propagatedBuildInputs = [];

  # TODO: Metadata etc
}