{ writeText
, formats
}:
let
  addr = import ../misc/wireguard-addresses.nix;
  atziluth = import ../hosts/atziluth/inventory-entry.nix addr;
  angela = import ../hosts/angela/inventory-entry.nix;
  mute = import ../hosts/mute/inventory-entry.nix;
in
(formats.yaml {}).generate "gradient-ansible-inventory.yml" ({
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
})