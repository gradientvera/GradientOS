/*
*   Overlay with packages that can be consumed without using a GradientOS configuration.
*/
final: prev:
let
  patchKanidm = kanidm: kanidm.overrideAttrs (prevAttrs: {
    patches = (if prevAttrs ? patches then prevAttrs.patches else []) ++ [
      ../pkgs/patches/kanidm/0001-Set-session-expiry-and-oauth-refresh-token-expiry-to-a-week.patch
    ];
  });
in
{
  beyond-all-reason-launcher = prev.callPackage ../pkgs/beyond-all-reason-launcher.nix { }; 

  fbink = prev.callPackage ../pkgs/fbink.nix { device = "LINUX"; };
  fbink-static = prev.pkgsStatic.callPackage ../pkgs/fbink.nix { device = "LINUX"; };
  fbink-kobo = prev.pkgsCross.armv7l-hf-multiplatform.callPackage ../pkgs/fbink.nix { device = "KOBO"; }; 
  fbink-kobo-static = prev.pkgsCross.armv7l-hf-multiplatform.pkgsStatic.callPackage ../pkgs/fbink.nix { device = "KOBO"; }; 

  fna3d = prev.callPackage ../pkgs/fna3d.nix { };

  force-xwayland = prev.callPackage ../pkgs/scripts/force-xwayland.nix { };

  gradient-ansible-lib = (prev.callPackage ../ansible/ansible-lib.nix { });
  gradient-ansible-inventory = prev.callPackage ../ansible/inventory.nix { };
  gradient-ansible-playbook = prev.callPackage ../ansible/playbook.nix { };

  godot-mono = prev.callPackage ../pkgs/godot-mono.nix { };

  jack-matchmaker = prev.callPackage ../pkgs/jack-matchmaker.nix { };

  kanidmWithSecretProvisioningAndGradientPatches = patchKanidm prev.kanidmWithSecretProvisioning;
  kanidmWithGradientPatches = patchKanidm prev.kanidm;

  moonraker-timelapse = prev.callPackage ../pkgs/moonraker-timelapse.nix { };

  starsector-gamescope-wrap = prev.callPackage ../pkgs/starsector-gamescope-wrap.nix { }; 

  # Klipper with accelerometer support. See: https://www.klipper3d.org/Measuring_Resonances.html#software-installation
  klipper = prev.klipper.overrideAttrs (finalAttrs: prevAttrs: {
    buildInputs = [
      prev.openblasCompat
      (prev.python3.withPackages (p: with p; [can cffi pyserial greenlet jinja2 markupsafe numpy matplotlib ]))
      ];
  });

  klipper-np3pro-firmware = prev.klipper-firmware.override {
    mcu = prev.lib.strings.sanitizeDerivationName "np3pro";
    gcc-arm-embedded = prev.gcc-arm-embedded-13;
    firmwareConfig = ../pkgs/klipper-np3pro-firmware/config;
  };

  klipper-kusba-firmware = (prev.klipper-firmware.override {
    mcu = prev.lib.strings.sanitizeDerivationName "kusba";
    gcc-arm-embedded = prev.gcc-arm-embedded-13;
    firmwareConfig = ../pkgs/klipper-kusba-firmware/config;
  }).overrideAttrs (finalAttrs: prevAttrs: {
    # Regular firmware derivation does not copy uf2 file.
    installPhase = prevAttrs.installPhase + ''
      cp out/klipper.uf2 $out/ || true
    '';
  });

}
