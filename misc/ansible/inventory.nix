let
  addr = import ../wireguard-addresses.nix;
  atziluth = import ../../hosts/atziluth/inventory-entry.nix addr;
  angela = import ../../hosts/angela/inventory-entry.nix;
  mute = import ../../hosts/mute/inventory-entry.nix;
in
{
  ungrouped = {
    hosts = {
      inherit atziluth angela mute;
    };
  };
  printers = {
    hosts = {
      inherit atziluth;
    };
  };
  vacuums = {
    hosts = {
      inherit angela mute;
    };
  };
}