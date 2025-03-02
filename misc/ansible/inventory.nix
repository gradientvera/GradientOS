let
  addr = import ../wireguard-addresses.nix;
  atziluth = import ../../hosts/atziluth/inventory-entry.nix addr;
in
{
  ungrouped = {
    hosts = {
      inherit atziluth;
    };
  };
  printers = {
    hosts = {
      inherit atziluth;
    };
  };
}