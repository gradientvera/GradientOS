{ gradient-ansible-lib }:
with gradient-ansible-lib.tasks;
[
  {
    name = "Angela play";
    hosts = [ "angela" ];
    tasks = [
      (ansibleBuiltinCopy { name = "Copy Sops secrets file"; } {
        src = ./secrets/secrets.yml;
        dest = "/opt/secrets.yml";
        owner = "root";
        group = "root";
        mode = "0444";
      })
    ];
  }
]