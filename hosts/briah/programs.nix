{ pkgs, ... }:
{

  environment.systemPackages = with pkgs; [
    v4l-utils
  ];

}