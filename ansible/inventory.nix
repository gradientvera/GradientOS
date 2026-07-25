{
  writeText,
  formats,
}:
let
  addr = import ../misc/wireguard-addresses.nix;
  atziluth = import ../hosts/atziluth/inventory-entry.nix addr;
  angela = import ../hosts/angela/inventory-entry.nix;
  roland = import ../hosts/roland/inventory-entry.nix;
in
(formats.yaml { }).generate "gradient-ansible-inventory.yml" ({
  ungrouped = {
    hosts = {
      inherit atziluth angela roland;
    };
  };
  printers = {
    hosts = {
      inherit atziluth;
    };
  };
  vacuums = {
    hosts = {
      inherit angela roland;
    };
  };
})
