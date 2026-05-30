{
  description = "GradientOS flake.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-master.url = "github:NixOS/nixpkgs/master";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-26.05";

    nixos-hardware = {
      url = "github:NixOS/nixos-hardware/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

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
    };
    
    colmena = {
      url = "github:zhaofengli/colmena";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.stable.follows = "nixpkgs-stable";
      inputs.flake-compat.follows = "flake-compat";
    };

    cryolitia-nur = {
      url = "github:Cryolitia/nur-packages/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    catppuccin = {
      url = "github:catppuccin/nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixpkgs-xr = {
      url = "github:nix-community/nixpkgs-xr";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    lanzaboote = {
      url = "github:nix-community/lanzaboote/v1.0.0";
      inputs.nixpkgs.follows = "nixpkgs";
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

  outputs = { self, nixpkgs, gradient-generator, jovian-nixos, sops-nix, nixos-hardware, cryolitia-nur, lanzaboote, ... }:
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
          lanzaboote.nixosModules.lanzaboote

          mixins.wine
          mixins.gnupg
          mixins.alloy
          mixins.podman
          #mixins.plymouth
          mixins.tailscale
          mixins.wireguard
          mixins.uwu-style
          mixins.upgrade-diff
          mixins.v4l2loopback
          mixins.vera-locale
          # mixins.virtualisation
          mixins.nix-store-serve
          mixins.binfmt-emulation

          mixins.graphical-steam

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
          mixins.tailscale
          mixins.upgrade-diff
          mixins.v4l2loopback
          mixins.neith-locale
          mixins.nix-store-serve
          
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
          tags = with colmena-tags; [ x86_64 steam-deck desktop neith ];
          allowLocalDeployment = true;
        };
      }

      {
        name = "erika";
        overlays = [ self.overlays.kernel-allow-missing ];

        modules = [
          lanzaboote.nixosModules.lanzaboote
          jovian-nixos.nixosModules.default

          mixins.tor
          mixins.wine
          mixins.gnupg
          mixins.plymouth
          mixins.tailscale
          mixins.wireguard
          mixins.uwu-style
          mixins.vera-locale
          mixins.upgrade-diff
          mixins.v4l2loopback
          # mixins.virtualisation
          mixins.nix-store-serve
          
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
          tags = with colmena-tags; [ x86_64 steam-deck desktop vera ];
          allowLocalDeployment = true;
        };
      }

      {
        name = "featherine";

        modules = [
          cryolitia-nur.nixosModules.bmi260
          lanzaboote.nixosModules.lanzaboote
          nixos-hardware.nixosModules.gpd-win-mini-2024
          
          #mixins.tor
          mixins.wine
          mixins.alloy
          mixins.gnupg
          #mixins.plymouth
          mixins.tailscale
          mixins.wireguard
          #mixins.uwu-style
          mixins.vera-locale
          mixins.upgrade-diff
          mixins.v4l2loopback
          #mixins.virtualisation
          #mixins.nix-store-serve
          mixins.only-suspend-then-hibernate
          
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
          mixins.nginx
          mixins.gnupg
          mixins.podman
          mixins.crowdsec
          mixins.steamcmd
          mixins.tailscale
          mixins.wireguard
          mixins.microsocks
          mixins.vera-locale
          mixins.upgrade-diff
          mixins.v4l2loopback
          # mixins.virtualisation
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
          tags = with colmena-tags; [ x86_64 server vera nightly ];
          allowLocalDeployment = true;
        };
      }

      {
        name = "briah";

        modules = [
          nixos-hardware.nixosModules.common-cpu-amd

          mixins.alloy
          mixins.nginx
          #mixins.podman
          mixins.crowdsec
          mixins.tailscale
          mixins.wireguard
          mixins.microsocks
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
          mixins.tailscale
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
            
            gradient.core.nixos.installer = true;
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
            
            gradient.core.nixos.installer = true;
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

    packages = self.lib.forAllSystemsWithOverlays [ self.overlays.gradientpkgs self.overlays.gradientos ] (pkgs: (self.overlays.gradientpkgs pkgs pkgs) // (self.overlays.home-assistant pkgs pkgs));
    legacyPackages = self.lib.forAllSystemsWithOverlays [ self.overlays.gradientpkgs self.overlays.gradientos self.overlays.home-assistant  ] (pkgs: (pkgs));

  };
}
