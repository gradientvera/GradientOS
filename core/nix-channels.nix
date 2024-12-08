{ self, ... }:
with self.inputs;
{

    # Pin channels to flake inputs.
    nix.registry.nixpkgs.flake = nixpkgs;
    nix.registry.nixpkgs-stable.flake = nixpkgs-stable;
    nix.registry.nixpkgs-master.flake = nixpkgs-master;
    nix.registry.self.flake = self;

    environment.etc."nix/inputs/nixpkgs".source = "${nixpkgs}";
    environment.etc."nix/inputs/nixpkgs-master".source = "${nixpkgs-master}";
    environment.etc."nix/inputs/nixpkgs-stable".source = "${nixpkgs-stable}";
    environment.etc."nix/inputs/self".source = "${self}";

    nix.nixPath = [ "/etc/nix/inputs" ];

}