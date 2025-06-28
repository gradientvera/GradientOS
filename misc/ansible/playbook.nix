[
  {
    name = "Common GradientOS play";
    hosts = "all";
    tasks = [

    ];
  }
]
++ (import ./vacuum-playbook.nix)
++ (import ../../hosts/atziluth/playbook.nix)
++ (import ../../hosts/angela/playbook.nix)
++ (import ../../hosts/mute/playbook.nix)