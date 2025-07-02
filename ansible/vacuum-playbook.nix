{ lib
, pkgsCross
, gradient-ansible-lib
}:
let
  alib = gradient-ansible-lib;
  pkgsAarch64 = pkgsCross.aarch64-multiplatform-musl;
  lixPkg = pkgsAarch64.pkgsStatic.lixPackageSets.latest.lix;
  sshPubKeys = import ../misc/ssh-pub-keys.nix;
  installNixPackage = pkg: alib.tasks.block { name = "Installing Nix package ${lib.getName pkg}"; } [
    (alib.tasks.nixCopyClosureWithRoot { inherit pkg; rootDest = "/data/nix-roots"; remoteProgram = "/opt/bin/nix-store"; })
    (alib.tasks.ansibleBuiltinFile { name = "Ensure existing ${lib.getName pkg} binary does not exist"; } { path = "/opt/bin/${baseNameOf (lib.getExe pkg)}"; state = "absent"; })
    (alib.tasks.nixMakeSymlinkToMainExe { inherit pkg; destPath = "/opt/bin"; })
  ];
  installNixPackages = pkgList: alib.tasks.block { name = "Installing Nix packages"; } (map (p: installNixPackage p) pkgList);
  installNixPackageCustom = pkg: binPath: destName: alib.tasks.block { name = "Installing Nix package ${lib.getName pkg} as ${destName}"; } [
    (alib.tasks.nixCopyClosureWithRoot { inherit pkg; rootDest = "/data/nix-roots"; remoteProgram = "/opt/bin/nix-store"; })
    (alib.tasks.ansibleBuiltinFile { name = "Ensure existing ${baseNameOf destName} binary does not exist"; } { path = "/opt/bin/${destName}"; state = "absent"; })
    (alib.tasks.nixMakeSymlinkCustom { inherit pkg; srcPath = binPath; destPath = "/opt/bin/${destName}"; })
  ];
  makeNixSymlink = name: alib.tasks.ansibleBuiltinFile { name = "Adding ${name} symlink"; } {
    path = "/opt/bin/${name}";
    src = "nix";
    force = true;
    owner = "root";
    group = "root";
    state = "link";
  };
  copyExecutable = name: src: dest: {
    inherit name;
    "ansible.builtin.copy" = {
      src = toString src;
      dest = toString dest;
      owner = "root";
      group = "root";
      mode = "0744";
    };
  };
  copySshAuthorizedKeys = name: dest: {
    inherit name;
    "ansible.builtin.copy" = {
      dest = toString dest;
      content = ''
        ${sshPubKeys.vera}
        ${sshPubKeys.hass}
      '';
      owner = "root";
      group = "root";
      mode = "0644";
    };
  };
in with alib.tasks;
[
  {
    name = "Robot Vacuums play";
    environment = {
      PATH = "$PATH:/opt/bin:/opt/sbin:/opt/usr/bin:/opt/libexec:{{ ansible_env.PATH }}";
      LD_LIBRARY_PATH = "$LD_LIBRARY_PATH:/opt/usr/lib";
    };
    hosts = [ "vacuums" ];
    tasks = [
      (copySshAuthorizedKeys "Copy SSH authorized keys to persistent data"
        "/mnt/misc/authorized_keys")

      (copySshAuthorizedKeys "Copy SSH authorized keys to temporary home"
        "/tmp/.ssh/authorized_keys")

      (copyExecutable "Copy Gradient Postboot Script"
        ../misc/vacuum/gradient_postboot.sh "/data/gradient_postboot.sh")

      (copyExecutable "Copy Gradient Provision Script"
        ../misc/vacuum/gradient_provision.sh "/data/gradient_provision.sh"
      )

      (copyExecutable "Copy Gradient Profile Script"
        ../misc/vacuum/gradient_shutdown.sh "/data/gradient_shutdown.sh")

      (copyExecutable "Copy Gradient Shutdown Script"
        ../misc/vacuum/gradient_profile.sh "/data/gradient_profile.sh")

      (copyExecutable "Copy Gradient Publish Photo Script"
        ../misc/vacuum/gradient_publish_photo.sh "/data/gradient_publish_photo.sh")

      (copyExecutable "Copy Gradient Sops Setup Script"
        ../misc/vacuum/gradient_sops_setup.sh "/data/gradient_sops_setup.sh")


      (opkg { }
      {
        state = "present";
        update_cache = true;
        executable = "/opt/bin/opkg";
        name = [
          "openssh-sftp-server"
          "python3"
          "python3-pip"

          "openssh-keygen"
          "strace"

          "imagemagick"
          "mosquitto-client-nossl"
          "jq"
        ];
      })

      (makeNixSymlink "lix")
      (makeNixSymlink "nix-build")
      (makeNixSymlink "nix-channel")
      (makeNixSymlink "nix-collect-garbage")
      (makeNixSymlink "nix-copy-closure")
      (makeNixSymlink "nix-daemon")
      (makeNixSymlink "nix-env")
      (makeNixSymlink "nix-hash")
      (makeNixSymlink "nix-instantiate")
      (makeNixSymlink "nix-prefetch-url")
      (makeNixSymlink "nix-shell")
      (makeNixSymlink "nix-store")

      (ansibleBuiltinStat { register = "lixStat"; } { path = "/opt/bin/nix"; })

      # If Nix binary does not exist yet, copy the binary over.
      (installPackageExe { pkg = lixPkg; dest = "/opt/bin/nix"; taskArgs = { when = "not (lixStat.stat.exists | default(false))"; }; })

      # Recreate Nix GC roots folder 
      (ansibleBuiltinFile { name = "Remove GC roots folder"; } { path = "/data/nix-roots"; state = "absent"; })
      (ansibleBuiltinFile { name = "Create GC roots folder"; } { path = "/data/nix-roots"; state = "directory"; owner = "root"; group = "root"; mode = "0777"; })

      # Install Nix packages with GC roots and symlinks to /opt/bin
      (installNixPackages 
      (with pkgsAarch64; [
        lixPkg
        sops
        (lilipod.overrideAttrs (prevAttrs: { PATH="${pkgsAarch64.su}/bin"; }))
        distrobox
        ssh-to-age
      ]))

      # And now we GC any old Nix paths >:)
      (ansibleBuiltinCommand { name = "Run Nix garbage collector"; } "nix-collect-garbage")
    ];
  }
]