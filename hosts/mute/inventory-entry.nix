let
  localAddresses = import ../../misc/local-addresses.nix;
in
{
  ansible_host = localAddresses.vacuum-mute;
  ansible_port = 222;
  ansible_user = "root"; # :(
  ansible_python_interpreter = "/opt/bin/python3";
}