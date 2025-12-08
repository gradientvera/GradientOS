{
  description = "GradientOS flake.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-master.url = "github:NixOS/nixpkgs/master";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-25.05";

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

    jovian-nixos.url = "github:Jovian-Experiments/Jovian-NixOS";

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-gaming = {
      url = "github:fufexan/nix-gaming";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    colmena = {
      url = "github:zhaofengli/colmena";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.stable.follows = "nixpkgs-stable";
      inputs.flake-compat.follows = "flake-compat";
    };

    gpd-fan-driver.url = "github:Cryolitia/gpd-fan-driver";
    gpd-fan-driver.inputs.nixpkgs.follows = "nixpkgs";

    catppuccin.url = "github:catppuccin/nix";

    nixpkgs-xr.url = "github:nix-community/nixpkgs-xr";

    lanzaboote = {
      url = "github:nix-community/lanzaboote/v0.4.3";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    klipper-adaptive-meshing-purging = {
      url = "github:kyleisah/Klipper-Adaptive-Meshing-Purging";
      flake = false;
    };

    crp3092 = {
      url = "git+ssh://git@github.com/CRP3092/Portafolio.git";
      flake = false;
    };

    ai-robots-txt = {
      url = "github:ai-robots-txt/ai.robots.txt";
      flake = false;
    };

    mmproxy-rs = {
      url = "github:gradientvera/mmproxy-rs";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, gradient-generator, jovian-nixos, sops-nix, nixos-hardware, gpd-fan-driver, lanzaboote, ... }:
  let
    addr = import ./misc/addresses.nix;
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
          mixins.wine
          mixins.gnupg
          mixins.alloy
          mixins.podman
          #mixins.plymouth
          mixins.wireguard
          mixins.uwu-style
          #mixins.tdarr-node
          mixins.upgrade-diff
          mixins.v4l2loopback
          mixins.vera-locale
          mixins.virtualisation
          mixins.nix-store-serve
          mixins.binfmt-emulation
          mixins.system76-scheduler

          mixins.graphical-steam
          mixins.graphical-sunshine

          mixins.restic-repository-hokma

          mixins.hardware-qmk
          mixins.hardware-wacom
          mixins.hardware-amdcpu
          mixins.hardware-amdgpu
          mixins.hardware-webcam
          mixins.hardware-bluetooth
          mixins.hardware-eaton-ups
          mixins.hardware-openrazer
          mixins.hardware-home-dcp-l2530dw
          mixins.hardware-xbox-one-controller
          # mixins.hardware-logitech-driving-wheels # TODO: Build broken
        ];

        users.vera.modules = [
          sops-nix.homeManagerModule
          ./users/vera/graphical/default.nix
        ];

        deployment = {
          targetHost = ips.gradientnet.bernkastel;
          tags = with colmena-tags; [ x86_64 desktop vera nightly ];
          allowLocalDeployment = true;
          buildOnTarget = true;
        };
      }

      {
        name = "neith-deck";
        overlays = [ self.overlays.kernel-allow-missing ];

        modules = [
          jovian-nixos.nixosModules.default

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

          mixins.wine
          mixins.gnupg
          mixins.wireguard
          mixins.uwu-style
          #mixins.tdarr-node
          mixins.vera-locale
          mixins.upgrade-diff
          mixins.v4l2loopback
          mixins.virtualisation
          mixins.graphical-steam
          mixins.nix-store-serve
          mixins.system76-scheduler
          
          mixins.hardware-qmk
          mixins.hardware-amdcpu
          mixins.hardware-amdgpu
          mixins.hardware-webcam
          mixins.hardware-bluetooth
          mixins.hardware-openrazer
          mixins.hardware-steamdeck-minimal
          mixins.hardware-home-dcp-l2530dw
          mixins.hardware-xbox-one-controller
          
          mixins.restic-repository-hokma
        ];

        users.vera.modules = [
          sops-nix.homeManagerModule
          ./users/vera/graphical/default.nix
        ];

        deployment = {
          targetHost = ips.gradientnet.beatrice;
          tags = with colmena-tags; [ x86_64 steam-deck desktop vera ];
          allowLocalDeployment = true;
        };
      }

      {
        name = "erika";
        overlays = [ self.overlays.kernel-allow-missing ];

        modules = [
          jovian-nixos.nixosModules.default

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
          lanzaboote.nixosModules.lanzaboote
          gpd-fan-driver.nixosModules.default
          nixos-hardware.nixosModules.gpd-win-mini-2024
          
          mixins.tor
          mixins.wine
          mixins.alloy
          mixins.gnupg
          mixins.plymouth
          mixins.wireguard
          mixins.uwu-style
          #mixins.tdarr-node
          mixins.vera-locale
          mixins.upgrade-diff
          mixins.v4l2loopback
          mixins.virtualisation
          #mixins.nix-store-serve
          mixins.jovian-decky-loader
          mixins.system76-scheduler
          
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
          tags = with colmena-tags; [ x86_64 desktop vera nightly ];
          allowLocalDeployment = true;
        };
      }

      {
        name = "asiyah";

        modules = [
          nixos-hardware.nixosModules.common-cpu-intel
          nixos-hardware.nixosModules.common-gpu-intel
          gradient-generator.nixosModules.default

          mixins.tor
          mixins.wine
          mixins.alloy
          mixins.gnupg
          mixins.podman
          mixins.crowdsec
          mixins.steamcmd
          mixins.wireguard
          mixins.vera-locale
          mixins.upgrade-diff
          mixins.v4l2loopback
          mixins.virtualisation
          mixins.nix-store-serve
          mixins.binfmt-emulation
          mixins.hardware-bluetooth
          mixins.hardware-eaton-ups
          mixins.hardware-intelgpu-vaapi
          mixins.restic-repository-hokma
        ];

        users.vera.modules = [
          sops-nix.homeManagerModule
        ];

        deployment = {
          targetHost = ips.gradientnet.asiyah;
          tags = with colmena-tags; [ x86_64 server vera nightly ];
          allowLocalDeployment = true;
        };
      }

      {
        name = "briah";

        modules = [
          nixos-hardware.nixosModules.common-cpu-amd

          mixins.alloy
          #mixins.podman
          mixins.crowdsec
          mixins.wireguard
          #mixins.vera-locale
          #mixins.upgrade-diff
          #mixins.restic-repository-hokma
        ];

        #users.vera.modules = [
          #sops-nix.homeManagerModule
        #];

        deployment = {
          targetHost = addr.briah;
          tags = with colmena-tags; [ x86_64 server vera nightly ];
          allowLocalDeployment = true;
        };
      }

      {
        name = "yetzirah";

        modules = [
          nixos-hardware.nixosModules.common-cpu-intel
          nixos-hardware.nixosModules.common-gpu-intel

          mixins.alloy
          mixins.podman
          mixins.wireguard
          mixins.vera-locale
          mixins.upgrade-diff
          mixins.virtualisation
          mixins.binfmt-emulation
          mixins.hardware-intelgpu-vaapi
          mixins.restic-repository-hokma
        ];

        users.vera.modules = [
          sops-nix.homeManagerModule
        ];

        deployment = {
          targetHost = ips.gradientnet.yetzirah;
          tags = with colmena-tags; [ x86_64 server vera nightly ];
          allowLocalDeployment = true;
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
            services.pulseaudio.enable = lib.mkForce false;
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
      home-assistant = import ./overlays/home-assistant.nix;
      kernel-allow-missing = import ./overlays/kernel-allow-missing.nix;
    };

    apps = self.lib.forAllSystemsWithOverlays [ self.overlays.gradientpkgs self.overlays.gradientos  ] (pkgs: (import ./ansible/apps.nix pkgs));

    packages = self.lib.forAllSystemsWithOverlays [ self.overlays.gradientpkgs self.overlays.gradientos ] (pkgs: self.overlays.gradientpkgs pkgs pkgs);
    legacyPackages = self.lib.forAllSystemsWithOverlays [ self.overlays.gradientpkgs self.overlays.gradientos self.overlays.home-assistant  ] (pkgs: (pkgs));

  };
}
