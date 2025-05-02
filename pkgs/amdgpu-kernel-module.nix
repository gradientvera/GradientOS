{ pkgs
, lib
, patches ? []
, kernel ? pkgs.linuxPackages_latest.kernel }:

# As per https://wiki.nixos.org/wiki/Linux_kernel#Patching_a_single_In-tree_kernel_module
pkgs.stdenv.mkDerivation {
  pname = "amdgpu-kernel-module";
  inherit (kernel) src version postPatch nativeBuildInputs;
  inherit patches;

  kernel_dev = kernel.dev;
  kernelVersion = kernel.modDirVersion;

  modulePath = "drivers/gpu/drm/amd/amdgpu";

  buildPhase = ''
    BUILT_KERNEL=$kernel_dev/lib/modules/$kernelVersion/build

    cp $BUILT_KERNEL/Module.symvers .
    cp $BUILT_KERNEL/.config        .
    cp $kernel_dev/vmlinux          .

    make "-j$NIX_BUILD_CORES" modules_prepare
    make "-j$NIX_BUILD_CORES" M=$modulePath modules
  '';

  installPhase = ''
    make \
      INSTALL_MOD_PATH="$out" \
      XZ="xz -T$NIX_BUILD_CORES" \
      M="$modulePath" \
      modules_install
  '';

  meta = {
    description = "AMD GPU kernel module";
    license = lib.licenses.gpl3;
  };
}