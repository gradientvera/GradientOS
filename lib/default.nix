self:
rec {

  gradientosSystem =
    { name
    , nixpkgs ? self.inputs.nixpkgs
    , ... 
    }@args:
    nixpkgs.lib.nixosSystem (gradientosSystemInternal args);

  gradientosSystemGenerator =
    { name
    , format
    , ...
    }@args:
    self.inputs.nixos-generators.nixosGenerate ((gradientosSystemInternal (args // { deployment = null; })) // { inherit format; });

  gradientosSystemColmena =
    { name
    , ...
    }@args:
    let
      gradientosConfig = gradientosSystemInternal args;
    in {
      meta = {
        nodeNixpkgs.${name} = gradientosConfig.pkgs;
        nodeSpecialArgs.${name} = gradientosConfig.specialArgs;
      };
      ${name} = gradientosConfig.modules;
    };

  gradientosSystemInternal =
    { name
    , nixpkgs ? self.inputs.nixpkgs
    , system ? "x86_64-linux"
    , modules ? [ ]
    , overlays ? [ ]
    , users ? { }
    , specialArgs ? { }
    , deployment ? {}
    , makeSystem ? true
    , importCore ? true
    , importHost ? true
    , importModules ? true
    , ...
    }:
    {

      inherit system;

      specialArgs =
      {
        inherit self;
        ports = mkPorts name;
      } // specialArgs;

      pkgs = import nixpkgs {
        inherit system;
        config = {
          allowUnfree = true;
          allowBroken = true;
          permittedInsecurePackages = [
            "dotnet-runtime-7.0.20" # TODO: Remove when not needed anymore
            "freeimage-3.18.0-unstable-2024-04-18" # TODO: Remove when not needed anymore
            "libsoup-2.74.3" # TODO: Remove when not needed anymore
          ];
        };
        overlays = [
          (import ../overlays/gradientos.nix self)
          (import ../overlays/gradientpkgs.nix)
          (import ../overlays/home-assistant.nix)
        ] ++ overlays;
      };

      modules = [
        (mkHostNameModule name)
        self.inputs.home-manager.nixosModules.home-manager
        self.inputs.mmproxy-rs.nixosModules.default
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.backupFileExtension = "bck";
          home-manager.extraSpecialArgs = { inherit self; };
        }
      ] ++ modules ++ (mkUserModules users)
        ++ (if importCore then [../core/default.nix] else [])
        ++ (if importHost then [../hosts/${name}/default.nix] else [])
        ++ (if importModules then [../modules/default.nix] else [])
        ++ (if deployment != null then [{ inherit deployment; }] else []);

    } // (if deployment != null then {
      # See https://github.com/zhaofengli/colmena/issues/60#issuecomment-1047199551
      extraModules = [ self.inputs.colmena.nixosModules.deploymentOptions ];
    } else {});

  mkHostNameModule = name:
    ({ ... }: { networking.hostName = self.inputs.nixpkgs.lib.mkForce name; });

  mkUserModules = users: # { test = { modules = [ ./example.nix ] } }
    with self.inputs.nixpkgs.lib;
    (lists.flatten (attrsets.mapAttrsToList
      (name: value: [
        ../users/${name}
        {
          home-manager.users.${name} = {
            imports = [
              ../users/common/home.nix
              ../users/${name}/home.nix
            ] ++ value.modules;
          };
        }
      ])
      users));

  forAllSystems = function: forAllSystemsCustom { config.allowUnfree = true; } function;
  forAllSystemsWithOverlays = overlays: function: forAllSystemsCustom { inherit overlays; config.allowUnfree = true; } function;
  forAllSystemsCustom = nixpkgsCfg: function:
    self.inputs.nixpkgs.lib.genAttrs [ "x86_64-linux" "aarch64-linux" ]
      (system: function (import self.inputs.nixpkgs (nixpkgsCfg // { inherit system; })));

  hasPortsFile = name: (builtins.pathExists ../hosts/${name}/misc/service-ports.nix);
  mkPorts = name: if (hasPortsFile name) then (builtins.import ../hosts/${name}/misc/service-ports.nix) else {};

  /*
  *   similar to switch statements in other programming languages.
        value -> any
        cases -> list of attrset "case"
        case -> {
          case -> any, must match value
          value -> any
        }
      a case with a null value is treated as the default match.
      in case of multiple matches, the first one is returned.
      in case of no matches, null is returned.
  */
  switch = value: cases: 
    let
     matches = builtins.filter (case: (case.case == value) || (case.case == null)) cases;
    in
      if matches == [] then null else (builtins.head(matches)).value;
}