{ pkgs, ... }:

{

  users.users.vera = {
    isNormalUser = true;
    linger = true;
    description = "Vera";
    shell = pkgs.fish;
    extraGroups = [ "networkmanager" "wheel" "audio" "render" "video" "pipewire" "dialout" "scanner" "lp" "libvirtd" "openrazer" "corectrl" "podman" "mediarr" "plugdev" ];
    hashedPassword = "$6$mTrvQELm1M1xnRO3$C8.NuZcgEKqW.QHFjABHk4Wkufa4FT0VpAzzgbuF1nwpx719/91uOpnq5JgY1C9LOi55d49VSp7H.KJ/iy74r.";
  };
  
  nix.settings.trusted-users = [ "vera" ];
}