{ lib, ... }:
let
  ssh-pub-keys = import ../misc/ssh-pub-keys.nix;
in {

  programs.mosh.enable = true;
  
  programs.ssh = {
    startAgent = true;
    hostKeyAlgorithms = [ "ssh-ed25519" "ssh-rsa" ];

    extraConfig = ''
Host * 
  IdentityFile /etc/ssh/ssh_host_ed25519_key
  IdentityFile ~/.ssh/id_ed25519
'';
  };

  # Enable the OpenSSH daemon.
  services.openssh = {
    
    enable = true;
    openFirewall = true;
    
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = lib.mkForce "prohibit-password";
      LogLevel = "VERBOSE";
      X11Forwarding = false;
    };

    extraConfig = ''
      AllowTcpForwarding yes
      AllowAgentForwarding no
      AllowStreamLocalForwarding no
      AuthenticationMethods publickey
    '';

    knownHosts = {
      "github.com" = {
        publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl";
      };
      "git.lix.systems" = {
        publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIL+li7S+VH+O2F8lehYE9oBmx7SLGGLl+UQDaTRA7iMM";
      };
      "ssh.gradient.moe" = {
        publicKey = ssh-pub-keys.forgejo;
      };
      "asiyah.gradient.moe" = {
        publicKey = ssh-pub-keys.asiyah;
      };
      "bernkastel.gradient.moe" = {
        publicKey = ssh-pub-keys.bernkastel;
      };
      "featherine.gradient.moe" = {
        publicKey = ssh-pub-keys.featherine;
      };
      "erika.gradient.moe" = {
        publicKey = ssh-pub-keys.erika;
      };
    };

    hostKeys = [
      {
        path = "/etc/ssh/ssh_host_ed25519_key";
        type = "ed25519";
      }
    ];

  };

  users.users.root.openssh.authorizedKeys.keys = with ssh-pub-keys; [
    vera
    
    # Ugh I hate that I have to do this
    forgejo-deployment
  ];
}