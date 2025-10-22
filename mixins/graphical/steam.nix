{ pkgs, ... }:

{

  hardware.steam-hardware.enable = true;

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    extest.enable = true;
    protontricks.enable = true;
    extraCompatPackages = with pkgs; [
      steam-play-none
      proton-ge-bin
    ];
  };

  # Helps some windows games running under Proton.
  boot.kernel.sysctl = {
    "vm.max_map_count" = 2147483642;
  };

  environment.sessionVariables = { WINEDEBUG = "-all"; };

  # See https://github.com/NixOS/nixpkgs/issues/230575
  # Breaks some other things...
  #environment.etc = {
  #  "ssl/certs/f387163d.0".source = "${pkgs.cacert.unbundled}/etc/ssl/certs/Starfield_Class_2_CA:0.crt";
  #  "ssl/certs/f081611a.0".source = "${pkgs.cacert.unbundled}/etc/ssl/certs/Go_Daddy_Class_2_CA:0.crt";
  #};

  environment.systemPackages = with pkgs; [
    steam-rom-manager
    steamtinkerlaunch
    protontricks
    protonup-qt
    steam-run
    lutris
  ];

}