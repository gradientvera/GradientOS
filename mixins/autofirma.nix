# See https://nix-community.github.io/autofirma-nix/installation_nixos_module.html
# copy-pasted from there lol
{ self, pkgs, config, ... }:
{

  imports = [
    self.inputs.autofirma-nix.nixosModules.default
  ];

  # The autofirma command becomes available system-wide
  programs.autofirma = {
    enable = true;
    firefoxIntegration.enable = true;
  };

  # DNIeRemote integration for using phone as NFC reader
  programs.dnieremote = {
    enable = true;
  };
  # Note: The Android app may not be available on Google Play for modern devices.
  # See the troubleshooting guide for installation alternatives.

  # The FNMT certificate configurator
  programs.configuradorfnmt = {
    enable = true;
    firefoxIntegration.enable = true;
  };

  # Firefox configured to work with AutoFirma
  programs.firefox = {
    enable = true;
    policies.SecurityDevices = {
      "OpenSC PKCS#11" = "${pkgs.opensc}/lib/opensc-pkcs11.so";
      "DNIeRemote" = "${config.programs.dnieremote.finalPackage}/lib/libdnieremotepkcs11.so";
    };
  };

  # Enable PC/SC smart card service
  services.pcscd.enable = true;

}