{ hosts, const }:
let
  mkAcceptSelf = user: { action = "accept"; src = [ user ]; dst = [ "${user}:*" ]; };
  neith = "neith@identity.gradient.moe";
  remie = "remie@identity.gradient.moe";
  vera = "vera@identity.gradient.moe";
in
{
  groups = {
    "group:gradient" = [ vera ];
    "group:constellation" = [ neith remie vera ];
    "group:users" = [ neith remie vera ];
  };
  acls = [
    (mkAcceptSelf neith)
    (mkAcceptSelf remie)
    (mkAcceptSelf vera)
    {
      action = "accept";
      src = [ "group:constellation" ];
      dst = [ "group:constellation:*" ];
    }
    {
      action = "accept";
      src = [ "group:users" ];
      dst = [ "autogroup:internet:*" ];
    }
  ];
}