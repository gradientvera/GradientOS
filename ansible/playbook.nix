{ callPackage
, formats
}:
(formats.yaml {}).generate "gradient-ansible-playbook.yml" 
([
  {
    name = "Common GradientOS play";
    hosts = "all";
    tasks = [

    ];
  }
]
++ (callPackage ./vacuum-playbook.nix { })
++ (callPackage ../hosts/atziluth/playbook.nix { })
++ (callPackage ../hosts/angela/playbook.nix { })
++ (callPackage ../hosts/mute/playbook.nix { }))