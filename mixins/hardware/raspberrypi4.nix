{ self, ... }:

{

  imports = [
    self.inputs.nixos-hardware.nixosModules.raspberry-pi-4
  ];

}