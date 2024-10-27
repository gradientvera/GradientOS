{
  description = "GradientOS flake.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-23.11";

    lix-module = {
      url = "https://git.lix.systems/lix-project/nixos-module/archive/2.91.0.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };

    gradient-generator = {
      url = "git+ssh://git@github.com/gradientvera/gradient-generator";
    };

    gradient-moe = {
      url = "git+ssh://git@github.com/gradientvera/gradient.moe";
    };

    constellation-moe = {
      url = "git+ssh://git@github.com/ConstellationNRV/constellation.moe";
      flake = false;
    };

    polycule-constellation-moe = {
      url = "git+ssh://git@github.com/ConstellationNRV/polycule.constellation.moe";
      flake = false;
    };

    jovian-nixos = {
      url = "github:Jovian-Experiments/Jovian-NixOS";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.nixpkgs-stable.follows = "nixpkgs-stable";
    };

    nix-gaming = {
      url = "github:fufexan/nix-gaming";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    ss14-watchdog = {
      url = "github:space-wizards/SS14.Watchdog";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    colmena = {
      url = "github:zhaofengli/colmena";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.stable.follows = "nixpkgs-stable";
      inputs.flake-compat.follows = "flake-compat";
    };

    declarative-flatpak.url = "github:GermanBread/declarative-flatpak/stable-v3";

    vdo-ninja = {
      url = "github:steveseguin/vdo.ninja/v24.4";
      flake = false;
    };

    catppuccin.url = "github:catppuccin/nix";

    klipper-adaptive-meshing-purging = {
      url = "github:kyleisah/Klipper-Adaptive-Meshing-Purging";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, home-manager, gradient-generator, jovian-nixos, sops-nix, nixos-hardware, nixos-generators, ss14-watchdog, declarative-flatpak, ... }:
  let
    ips = import ./misc/wireguard-addresses.nix;
    colmena-tags = import ./misc/colmena-tags.nix;
    mkFlake = (import ./lib/mkFlake.nix self);
    mixins = import ./nixosMixins.nix;
    modules = import ./nixosModules.nix;
  in
  mkFlake {

    gradientosConfigurations = [
        
      {
        name = "bernkastel";

        modules = [
          declarative-flatpak.nixosModules.default

          mixins.tor
          mixins.wine
          mixins.gnupg
          mixins.monado
          mixins.podman
          mixins.plymouth
          mixins.wireguard
          mixins.uwu-style
          mixins.upgrade-diff
          mixins.v4l2loopback
          mixins.vera-locale
          mixins.virtualisation
          mixins.nix-store-serve
          mixins.aarch64-emulation
          mixins.system76-scheduler
          mixins.declarative-flatpak

          mixins.graphical-steam
          mixins.graphical-sunshine

          mixins.restic-repository-hokma

          mixins.hardware-qmk
          mixins.hardware-wacom
          mixins.hardware-amdcpu
          mixins.hardware-amdgpu
          mixins.hardware-webcam
          mixins.hardware-bluetooth
          mixins.hardware-openrazer
          mixins.hardware-home-dcp-l2530dw
          mixins.hardware-xbox-one-controller
          mixins.hardware-logitech-driving-wheels
        ];

        users.vera.modules = [
          sops-nix.homeManagerModule
          ./users/vera/graphical/default.nix
        ];

        deployment = {
          targetHost = ips.gradientnet.bernkastel;
          tags = with colmena-tags; [ x86_64 desktop vera ];
          allowLocalDeployment = true;
          buildOnTarget = true;
        };
      }

      {
        name = "neith-deck";
        overlays = [ self.overlays.kernel-allow-missing ];

        modules = [
          jovian-nixos.nixosModules.default
          declarative-flatpak.nixosModules.default

          mixins.wine
          mixins.gnupg
          mixins.plymouth
          mixins.wireguard
          mixins.uwu-style
          mixins.upgrade-diff
          mixins.v4l2loopback
          mixins.neith-locale
          mixins.nix-store-serve
          mixins.system76-scheduler
          mixins.declarative-flatpak
          
          mixins.graphical-steam
          
          mixins.hardware-amdcpu
          mixins.hardware-amdgpu
          mixins.hardware-webcam
          mixins.hardware-bluetooth
          mixins.hardware-steamdeck
        ];

        users.neith.modules = [
          sops-nix.homeManagerModule
          ./users/neith/graphical/default.nix
        ];

        deployment = {
          targetHost = ips.lilynet.neith-deck;
          tags = with colmena-tags; [ x86_64 steam-deck desktop neith ];
          allowLocalDeployment = true;
        };
      }

      {
        name = "beatrice";
        overlays = [ self.overlays.kernel-allow-missing ];

        modules = [
          jovian-nixos.nixosModules.default
          declarative-flatpak.nixosModules.default
          
          mixins.wine
          mixins.gnupg
          mixins.wireguard
          mixins.uwu-style
          mixins.vera-locale
          mixins.upgrade-diff
          mixins.v4l2loopback
          mixins.virtualisation
          mixins.nix-store-serve
          mixins.declarative-flatpak
          
          mixins.hardware-qmk
          mixins.hardware-amdcpu
          mixins.hardware-amdgpu
          mixins.hardware-webcam
          mixins.hardware-bluetooth
          mixins.hardware-openrazer
          mixins.hardware-steamdeck-minimal
          mixins.hardware-home-dcp-l2530dw
          
          mixins.restic-repository-hokma
        ];

        users.vera.modules = [
          sops-nix.homeManagerModule
          ./users/vera/graphical/default.nix
        ];

        deployment = {
          targetHost = ips.gradientnet.beatrice;
          tags = with colmena-tags; [ x86_64 steam-deck desktop server vera ];
          allowLocalDeployment = true;
        };
      }

      {
        name = "erika";
        overlays = [ self.overlays.kernel-allow-missing ];

        modules = [
          jovian-nixos.nixosModules.default
          declarative-flatpak.nixosModules.default
          
          mixins.tor
          mixins.wine
          mixins.gnupg
          mixins.plymouth
          mixins.wireguard
          mixins.uwu-style
          mixins.vera-locale
          mixins.upgrade-diff
          mixins.v4l2loopback
          mixins.virtualisation
          mixins.nix-store-serve
          mixins.system76-scheduler
          mixins.declarative-flatpak
          
          mixins.graphical-steam
          
          mixins.restic-repository-hokma

          mixins.hardware-qmk
          mixins.hardware-amdcpu
          mixins.hardware-amdgpu
          mixins.hardware-webcam
          mixins.hardware-bluetooth
          mixins.hardware-steamdeck
          mixins.hardware-openrazer
          mixins.hardware-home-dcp-l2530dw
          mixins.hardware-xbox-one-controller
        ];

        users.vera.modules = [
          sops-nix.homeManagerModule
          ./users/vera/graphical/default.nix
        ];

        deployment = {
          targetHost = ips.gradientnet.erika;
          tags = with colmena-tags; [ x86_64 steam-deck desktop vera ];
          allowLocalDeployment = true;
        };
      }

      {
        name = "featherine";

        modules = [
          jovian-nixos.nixosModules.default
          declarative-flatpak.nixosModules.default
          nixos-hardware.nixosModules.gpd-win-mini-2024
          
          mixins.tor
          mixins.wine
          mixins.gnupg
          mixins.plymouth
          mixins.wireguard
          mixins.uwu-style
          mixins.vera-locale
          mixins.upgrade-diff
          mixins.v4l2loopback
          mixins.virtualisation
          #mixins.nix-store-serve
          mixins.system76-scheduler
          mixins.declarative-flatpak
          
          mixins.graphical-steam

          mixins.restic-repository-hokma

          mixins.hardware-qmk
          mixins.hardware-amdcpu
          mixins.hardware-amdgpu
          mixins.hardware-webcam
          mixins.hardware-bluetooth
          mixins.hardware-openrazer
          mixins.hardware-home-dcp-l2530dw
          mixins.hardware-xbox-one-controller
        ];

        users.vera.modules = [
          sops-nix.homeManagerModule
          ./users/vera/graphical/default.nix
        ];

        deployment = {
          targetHost = ips.gradientnet.featherine;
          tags = with colmena-tags; [ x86_64 desktop vera ];
          allowLocalDeployment = true;
        };
      }

      {
        name = "asiyah";

        modules = [
          nixos-hardware.nixosModules.common-cpu-intel
          # nixos-hardware.nixosModules.common-gpu-intel
          gradient-generator.nixosModules.default

          mixins.tor
          mixins.wine
          mixins.gnupg
          mixins.podman
          mixins.steamcmd
          mixins.wireguard
          mixins.vera-locale
          mixins.upgrade-diff
          mixins.v4l2loopback
          mixins.virtualisation
          mixins.nix-store-serve
          mixins.aarch64-emulation
          mixins.hardware-intelgpu-vaapi
          mixins.restic-repository-hokma
        ];

        users.vera.modules = [
          sops-nix.homeManagerModule
        ];

        deployment = {
          targetHost = ips.gradientnet.asiyah;
          tags = with colmena-tags; [ x86_64 server vera ];
          allowLocalDeployment = true;
        };
      }

       {
        name = "briah";
        system = "aarch64-linux";
        overlays = [ self.overlays.kernel-allow-missing ];
        
        modules = [
          ss14-watchdog.nixosModules.default

          mixins.gnupg
          mixins.wireguard
          mixins.vera-locale
          mixins.upgrade-diff
          mixins.v4l2loopback
          mixins.nix-store-serve
          mixins.hardware-bluetooth
          mixins.hardware-raspberrypi4
          mixins.restic-repository-hokma
          ({ pkgs, ... }: { nix.package = pkgs.lix; })
        ];

        users.vera.modules = [
          sops-nix.homeManagerModule
        ];

        generators = [ "sd-aarch64" ];

        importLix = false; # Failing to cross-compile on aarch64

        deployment = {
          targetHost = ips.gradientnet.briah;
          tags = with colmena-tags; [ aarch64 raspberry-pi server vera ];
          allowLocalDeployment = true;
          #buildOnTarget = true;
        };
      }

      {
        name = "GradientOS-x86_64";
        system = "x86_64-linux";

        modules = [
          ({ modulesPath, lib, ... }:
          {
            imports = [ (modulesPath + "/installer/cd-dvd/installation-cd-graphical-calamares-plasma6.nix") ];
            boot.initrd.systemd.enable = lib.mkForce false;
          })
        ];

        generators = [ "install-iso" ];

        importHost = false;
        makeSystem = false;
      }

      {
        name = "GradientOS-x86_64-steamdeck";
        system = "x86_64-linux";
        overlays = [ self.overlays.kernel-allow-missing ];

        modules = [
          jovian-nixos.nixosModules.default
          ({ modulesPath, lib, ... }:
          {
            imports = [ (modulesPath + "/installer/cd-dvd/installation-cd-graphical-calamares-plasma6.nix") ];
            jovian.devices.steamdeck.enable = true;
            jovian.devices.steamdeck.enableXorgRotation = false;
            hardware.pulseaudio.enable = lib.mkForce false;
            boot.initrd.systemd.enable = lib.mkForce false;
          })
        ];

        generators = [ "install-iso" ];

        importHost = false;
        makeSystem = false;
      }
      
    ];

    nixosModules = modules // (nixpkgs.lib.attrsets.mapAttrs' (name: value: { name = "mixin-" + name; inherit value; }) mixins);

    overlays = {
      default = self.overlays.gradientpkgs;
      gradientpkgs = import ./overlays/gradientpkgs.nix;
      gradientos = import ./overlays/gradientos.nix self;
      kernel-allow-missing = import ./overlays/kernel-allow-missing.nix;
    };

    apps = self.lib.forAllSystemsWithOverlays [ self.overlays.gradientpkgs self.overlays.gradientos  ] (pkgs: (import ./misc/ansible/apps.nix pkgs));

    packages = self.lib.forAllSystems (pkgs: self.overlays.gradientpkgs pkgs pkgs);
    legacyPackages = self.lib.forAllSystemsWithOverlays [ self.overlays.gradientpkgs self.overlays.gradientos  ] (pkgs: (pkgs));
  };
}
