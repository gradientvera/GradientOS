{ callPackage
, formats
}:
let
  gradient-ansible-lib = (callPackage ./ansible-lib.nix { });
in
(formats.yaml {}).generate "gradient-ansible-playbook.yml" 
([
  {
    name = "Common GradientOS play";
    hosts = "all";
    tasks = [

    ];
  }
]
++ (callPackage ./vacuum-playbook.nix { inherit gradient-ansible-lib; })
++ (callPackage ../hosts/atziluth/playbook.nix { inherit gradient-ansible-lib; })
++ (callPackage ../hosts/angela/playbook.nix { inherit gradient-ansible-lib; })
++ (callPackage ../hosts/mute/playbook.nix { inherit gradient-ansible-lib; }))