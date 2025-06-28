let
  copyScriptFile = src: dest: {
    inherit src dest;
    owner = "root";
    group = "root";
    mode = "0744";
  };
in
[
  {
    name = "Robot Vacuums play";
    hosts = [ "vacuums" ];
    environment = {
      PATH = "$PATH:/opt/bin:/opt/sbin:/opt/usr/bin:/opt/libexec";
      LD_LIBRARY_PATH = "$LD_LIBRARY_PATH:/opt/usr/lib";
    };
    tasks = [
      {
        name = "Copy Gradient Postboot Script";
        "ansible.builtin.copy" = copyScriptFile (toString ../vacuum/gradient_postboot.sh) "/data/gradient_postboot.sh";
      }
      {
        name = "Copy Gradient Provision Script";
        "ansible.builtin.copy" = copyScriptFile (toString ../vacuum/gradient_provision.sh) "/data/gradient_provision.sh";
      }
      {
        name = "Copy Gradient Profile Script";
        "ansible.builtin.copy" = copyScriptFile (toString ../vacuum/gradient_shutdown.sh) "/data/gradient_shutdown.sh";
      }
      {
        name = "Copy Gradient Shutdown Script";
        "ansible.builtin.copy" = copyScriptFile (toString ../vacuum/gradient_profile.sh) "/data/gradient_profile.sh";
      }

      # These two should already be installed, but just in case...
      {
        name = "Install OpenSSH SFTP Server";
        "community.general.opkg" = {
          name = "python3";
          state = "present";
        };
      }
      {
        name = "Install Python 3";
        "community.general.opkg" = {
          name = "python3";
          state = "present";
        };
      }

    ];
  }
]