{ gradient-ansible-lib }:
with gradient-ansible-lib.tasks;
[
  {
    name = "*Mute play";
    hosts = [ "mute" ];
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