/* 
  gradientosConfigurations = [
    {
      name = "example-machine";
      modules = [
        ./example-module.nix
      ];
      users.example.modules = [
        ./example-home-manager-module.nix
      ];
      generators = [];
      deployment = {};
    }
  ]
*/
self: { gradientosConfigurations ? [], ... }@args:
let 
  lib = import ./default.nix self;
  nixpkgsLib = self.inputs.nixpkgs.lib;
in {
  inherit lib;

  nixosConfigurations = 
  let
    configurations = builtins.filter (x: (x.makeSystem or true)) gradientosConfigurations;
  in builtins.listToAttrs 
    (map (x: { name = x.name; value = lib.gradientosSystem x; }) configurations);

  colmena = nixpkgsLib.lists.foldr (a: b: (nixpkgsLib.attrsets.recursiveUpdate a b))
    {
      meta = {
        description = "GradientOS machines";
        nixpkgs = import self.inputs.nixpkgs { system = "x86_64-linux"; };
      };
    }
    (map (x: lib.gradientosSystemColmena x) (builtins.filter (x: x.makeSystem or true) gradientosConfigurations));

  packages = 
  let
    configurations = builtins.filter (x: (builtins.length x.generators or []) != 0) gradientosConfigurations;
    x86_64-linux-configurations = builtins.filter (x: x.system or "x86_64-linux" == "x86_64-linux") configurations;
    aarch64-linux-configurations = builtins.filter (x: x.system or "x86_64-linux" == "aarch64-linux") configurations;
    generate = config: (map (x: { name = config.name+"-"+x; value = lib.gradientosSystemGenerator (config // { format = x; }); })
      (nixpkgsLib.lists.unique config.generators or []));
    generateMany = configs: builtins.listToAttrs (nixpkgsLib.lists.flatten (map (x: generate x) configs));
  in (nixpkgsLib.attrsets.recursiveUpdate ({
    "x86_64-linux" = generateMany x86_64-linux-configurations;
    "aarch64-linux" = generateMany aarch64-linux-configurations;
  }) (args.packages or {}));

} // removeAttrs args [ "gradientosConfigurations" "packages" ]