{ ... }:
{

    # Group that allows users to start systemd units
    users.groups.systemd-start-units = {};
    # Group that allows users to restart systemd units
    users.groups.systemd-stop-units = {};
    # Group that allows users to restart systemd units
    users.groups.systemd-restart-units = {};

    security.polkit.extraConfig = ''
      polkit.addRule(function(action, subject) {
          if (action.id == "org.freedesktop.systemd1.manage-units") {
              var verb = action.lookup("verb");
              if (verb == "start" && subject.isInGroup("systemd-start-units")) {
                return polkit.Result.YES;
              }
              
              if (verb == "stop" && subject.isInGroup("systemd-stop-units")) {
                return polkit.Result.YES;
              }
              
              if (verb == "restart" && subject.isInGroup("systemd-restart-units")) {
                return polkit.Result.YES;
              }
          }
      });
    '';

}