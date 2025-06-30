## GradientOS
Flake for different NixOS system configurations.
GradientOS supports the [auxolotl](https://auxolotl.org/) and [Lix](https://lix.systems/) projects and so should you!

### Features
- Encrypted secrets using [sops-nix](https://github.com/Mic92/sops-nix)
- Optional Steam Deck support using [Jovian NixOS](https://github.com/Jovian-Experiments/Jovian-NixOS)
- Supports deployments using [Colmena](https://github.com/zhaofengli/colmena)
- Spaghetti!

### Overview
- **[core](core)**: configurations that are shared across all machines
- **[hosts](hosts)**: configurations specific to certain machines
- **[lib](lib)**: utility functions
- **[misc](misc)**: for files without a clear category
- **[ansible]**: ansible playbook written entirely in nixlang
- **[misc/vacuum]**: scripts for my rooted robot vacuums to provision a writable overlay rootfs to chroot into 
- **[mixins](mixins)**: configuration presets for certain programs and services
- **[mixins/graphical](mixins/graphical)**: configuration presets for certain graphical programs and services
- **[mixins/hardware](mixins/hardware)**: configuration presets specific to certain hardware
- **[mixins/home](mixins/home)**: configuration presets for certain programs and services, using [home-manager](https://github.com/nix-community/home-manager)
- **[mixins/pipewire](mixins/pipewire)**: configuration presets for Pipewire
- **[modules](modules)**: custom NixOS modules
- **[overlays](overlays)**: nixpkgs overlays
- **[pkgs](pkgs)**: custom packages
- **[users](users)**: configurations specific to certain users, using [home-manager](https://github.com/nix-community/home-manager)
- **[users/common](users/common)**: configurations shared across all users, using [home-manager](https://github.com/nix-community/home-manager)

### Modules
- **[default](modules/default.nix)**: imports every other module in this list
- **[tmpfiles-check](modules/tmpfiles-check.nix)**: support for system-reproducibility-breaking, declarative mutable files using tmpfiles.d
- **[substituter-switcher](modules/substituter-switcher.nix)**: adds a command to activate or deactivate optional substituters specified in your config

### Machines

- **[bernkastel](hosts/bernkastel)**: Custom Gaming Desktop.
- **[featherine](hosts/featherine)**: GPD Win Mini 2024.
- **[erika](hosts/erika)**: Steam Deck OLED.
- **[beatrice](hosts/beatrice)**: Steam Deck LCD used as a Server.
- **[neith-deck](hosts/neith-deck)**: Steam Deck LCD.
- **[asiyah](hosts/asiyah)**: Custom Home Server.
- **[yetzirah](hosts/yetzirah)**: ThinkCentre M900 Tiny Home Server.
- **[briah](hosts/briah)**: Raspberry Pi 4 Home Server.

#### Managed with Ansible

- **[angela](hosts/angela)**: Xiaomi X10+ Robot Vacuum running a rooted firmware.
- **[\*mute](hosts/mute)**: Xiaomi X10+ Robot Vacuum running a rooted firmware.
- **[atziluth](hosts/atziluth)**: (WIP) BigTechTree CB1 running Armbian, Voron 2.4r2.

### FAQ

> Should I use this on my machine?

No, these configurations make many assumptions about the hardware they are running on, so they will not work on your machine.<br>
Feel free to take inspiration from them or modify them so they work for you, though!

> Should I expect this flake's outputs to be stable?

No, always expect breaking changes. You might be better off copying whatever you need into your config rather than consuming this flake directly.<br>
Just don't forget to leave a comment with attribution and this project's license!

