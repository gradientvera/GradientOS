pkgs:
{
  ansible-playbook = {
    type = "app";
    program = builtins.toString (pkgs.writeShellScript "gradient-ansible-playbook.sh" 
      "${pkgs.ansible}/bin/ansible-playbook -i \"${pkgs.gradient-ansible-inventory}\" \"${pkgs.gradient-ansible-playbook}\"");
  };
}