{ }:
let
  sshPubKeys = import ../misc/ssh-pub-keys.nix;
  installOpkg = name: {
    name = "Install ${name}";
    "community.general.opkg" = {
      inherit name;
      state = "installed";
      executable = "/opt/bin/opkg";
    };
  };
  copyScriptFile = name: src: dest: {
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
in
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

      (copyScriptFile "Copy Gradient Postboot Script"
        ../misc/vacuum/gradient_postboot.sh "/data/gradient_postboot.sh")

      (copyScriptFile "Copy Gradient Provision Script"
        ../misc/vacuum/gradient_provision.sh "/data/gradient_provision.sh"
      )

      (copyScriptFile "Copy Gradient Profile Script"
        ../misc/vacuum/gradient_shutdown.sh "/data/gradient_shutdown.sh")

      (copyScriptFile "Copy Gradient Shutdown Script"
        ../misc/vacuum/gradient_profile.sh "/data/gradient_profile.sh")

      (copyScriptFile "Copy Gradient Publish Photo Script"
        ../misc/vacuum/gradient_publish_photo.sh "/data/gradient_publish_photo.sh")

      # These two should already be installed, but just in case...
      (installOpkg "openssh-sftp-server")
      (installOpkg "python3")

      (installOpkg "imagemagick")
      (installOpkg "mosquitto-client-nossl")
      (installOpkg "jq")

    ];
  }
]