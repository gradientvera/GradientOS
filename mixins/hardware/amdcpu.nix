{ self, config, lib, pkgs, ... }:

{

  imports = [
    self.inputs.nixos-hardware.nixosModules.common-cpu-amd-pstate
    self.inputs.nixos-hardware.nixosModules.common-cpu-amd-zenpower
  ];

  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  # System Management Unit
  hardware.cpu.amd.ryzen-smu.enable = true;

  environment.systemPackages = with pkgs; [
    ryzenadj
    zenstates
  ];

}