{ ... }:
{
  boot.binfmt.emulatedSystems = [
    "aarch64-linux"
    "armv7l-linux"
  ];

  boot.binfmt.preferStaticEmulators = true;
}