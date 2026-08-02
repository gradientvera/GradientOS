{ pkgs, ... }:

{

  users.users.neith = {
    isNormalUser = true;
    linger = true;
    description = "Neith";
    shell = pkgs.fish;
    extraGroups = [
      "networkmanager"
      "wheel"
      "audio"
      "video"
      "pipewire"
      "scanner"
      "lp"
    ];
    # Use passwd and set password declaratively on first boot
    initialPassword = "";
  };

  nix.settings.trusted-users = [ "neith" ];
}
