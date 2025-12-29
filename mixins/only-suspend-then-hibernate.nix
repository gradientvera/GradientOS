{ pkgs, lib, ... }:
{

  # Always suspend-then-hibernate
  systemd.services.systemd-suspend.serviceConfig.ExecStart = lib.mkForce "${pkgs.systemd}/lib/systemd/systemd-sleep suspend-then-hibernate";

}