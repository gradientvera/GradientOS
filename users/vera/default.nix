{ pkgs, ... }:

{

  users.users.vera = {
    isNormalUser = true;
    linger = true;
    description = "Vera";
    shell = pkgs.fish;
    extraGroups = [
      "networkmanager"
      "wheel"
      "audio"
      "render"
      "video"
      "pipewire"
      "dialout"
      "scanner"
      "lp"
      "libvirtd"
      "openrazer"
      "corectrl"
      "podman"
      "mediarr"
      "plugdev"
      "i2c"
      "uinput"
    ];
    # Use passwd and set password declaratively on first boot
    initialPassword = "";
  };

  nix.settings.trusted-users = [ "vera" ];
}
