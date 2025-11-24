{ lib
, fetchFromGitHub
, rustPlatform
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "udppp";
  version = "unstable-2022-04-20";

  src = fetchFromGitHub {
    owner = "b23r0";
    repo = "udppp";
    rev = "eefcc13a0a889af1baa864ebff040028c2777f5c";
    hash = "sha256-tZnIzpZWjOVl1WMZl29RXFE9tKAk8Zq685olh/LsoDo=";
  };

  cargoPatches = [
    ./0001-Add-ipv6-support-for-reverse-proxy-mode.patch
  ];

  cargoHash = "sha256-F3WWL3hWFmYLzsRYxO9+4ZWdydSYUk6qu6BYXSaatEc=";

  meta = {
    description = "Rust implementation of UDP protocol MMProxy ";
    homepage = "https://github.com/b23r0/udppp";
    license = lib.licenses.mit;
  };
})
