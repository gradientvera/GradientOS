# Broken!!!
# I can't get this piece of shit to work
# but I spent like an hour on this so
# I'm not gonna delete it lol

{ lib
, php83
, nodejs
, stdenvNoCC
, chromium
, npmHooks
, fetchNpmDeps
, fetchFromGitHub
}:
let
  php = php83.withExtensions ({ enabled, all, ...}: with all; [ imagick iconv filter ] ++ enabled);
  pname = "byos_laravel";
  version = "0.1.9";
  src = fetchFromGitHub {
    owner = "usetrmnl";
    repo = pname;
    rev = version;
    hash = "sha256-+n/79W6+YJyCb3llms4jG96aWessWIGyfs9hE08xqF8=";
  };
in
stdenvNoCC.mkDerivation
{
  inherit pname version src;

  env = {
    PUPPETEER_SKIP_DOWNLOAD = true;
  };

  npmDeps = fetchNpmDeps {
    inherit src;
    name = "${pname}-npm-deps-${version}";
    hash = "sha256-/ZO2QJAbUinU4XuVRsUs2BgPKky3vDtot663A0BX90Y=";
  };

  composerRepository = php.mkComposerRepository {
    inherit pname version src;
    composerNoDev = true;
    composerNoPlugins = true;
    composerNoScripts = true;
    composeLock = "${src}/compose.lock";
    vendorHash = "sha256-MlU2CycdNSxOX9Obi/UW3QIO3Tb4K1DXBYtgUtE+E/U=";
  };

  buildInputs = [
    php
  ];

  nativeBuildInputs = [
    nodejs
    php.packages.composer
    npmHooks.npmConfigHook
    php.composerHooks.composerInstallHook
  ];

  postInstall = ''
    wrapProgram $out/bin/* \
      --set PUPPETEER_EXECUTABLE_PATH ${chromium}/bin/chromium
  '';

}