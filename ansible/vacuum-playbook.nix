{ pkgsCross
, gradient-ansible-lib
}:
let
  alib = gradient-ansible-lib;
  pkgsAarch64 = pkgsCross.aarch64-multiplatform;
  sshPubKeys = import ../misc/ssh-pub-keys.nix;
  installOpkg = name: {
    name = "Install ${name}";
    "community.general.opkg" = {
      inherit name;
      state = "installed";
      executable = "/opt/bin/opkg";
    };
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
in with alib;
[
  {
    name = "Robot Vacuums play";
    environment = {
      PATH = "$PATH:/opt/bin:/opt/sbin:/opt/usr/bin:/opt/libexec";
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

      # These two should already be installed, but just in case...
      (installOpkg "openssh-sftp-server")
      (installOpkg "python3")

      (installOpkg "dropbearconvert")
      (installOpkg "openssh-keygen")

      (installOpkg "imagemagick")
      (installOpkg "mosquitto-client-nossl")
      (installOpkg "jq")

      # Sops secrets support
      (installPackageExe { pkg = pkgsAarch64.sops; dest = "/opt/bin/sops"; })

      # Does not actually work yet :(
      (installPackageExe { pkg = pkgsAarch64.ssh-to-age; run = "/bin/ssh-to-age"; dest = "/opt/bin/ssh-to-age"; })

    ];
  }
]