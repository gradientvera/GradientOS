{ pkgs, ... }:
{

  environment.systemPackages = with pkgs; [
    unstable.wlr-randr
  ];

}