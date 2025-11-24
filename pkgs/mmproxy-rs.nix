{ lib
, fetchFromGitHub
, rustPlatform
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "udppp";
  version = "unstable-2023-05-22";

  src = fetchFromGitHub {
    owner = "saiko-tech";
    repo = "mmproxy-rs";
    rev = "d54231afc24d29ea333baf941d4cf6506e0c1f25";
    hash = "sha256-5lqhOd9UTf4wPReUun8/zL1/7iuZgbWDpGaoVMZkB3g=";
  };

  cargoHash = "sha256-OrBgSco0By0/ZRtkGli4rV6Pmu0vVvj+bIH4nlYMoMs=";

  meta = {
    mainProgram = "mmproxy";
    description = "Rust implementation of TCP + UDP Proxy Protocol (aka. MMProxy)";
    homepage = "https://github.com/saiko-tech/mmproxy-rs";
    license = lib.licenses.mit;
  };
})
