{ pkgs, ... }:
{

  services.redis = {
    package = pkgs.valkey;
    vmOverCommit = true;
  };

}