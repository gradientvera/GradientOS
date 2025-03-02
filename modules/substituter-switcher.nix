/*

  Module that adds a "substituters" command, which allows you to activate or
  deactivate some optional substituters as specified on your configuration.

  This is helpful for setting up substituters between your machines, as your
  builds will not fail if one of them is not online 24/7.

  USAGE:
    Specify "gradient.substituters" on your config.
    It should be an attribute set where the name is the substituter identifier
    and the value is a string containing the substituter URL.

  REMARKS:
    After activating this module on your system, you will need to restart for the
    NIX_USER_CONF_FILES environment variable to be set properly, otherwise it won't work.
  
  EXAMPLE:
    // In your config...
    gradient.substituters = {
      nixos = "https://cache.nixos.org"
    };

    // And then, in your terminal, with enough privileges...
    # substituters activate nixos

    // Check the help message for more info!
    # substituters --help

*/
{ config, pkgs, lib, ... }:
let
  cfg = config.gradient.substituters;
  timeout = "${pkgs.coreutils}/bin/timeout";
  confPath = "/etc/nix/substituter-switcher.conf";
  script = pkgs.writers.writeNuBin "substituters" ''

def readJson [] {
  cat "/etc/nix/substituter-switcher.json" | from json | transpose key value
}

def restoreConf [] {
  rm -f "${confPath}"
  touch "${confPath}"
}

def makeConfWritable [] {
  if ("${confPath}" | path type) != "symlink" {
    return
  }
  rm "${confPath}"
  touch "${confPath}"
}

# Allows you to activate an optional substituter
def "main activate" [
    ...names: string, # The substituter or substituters to activate.
    --all (-a) # Activates all optional substituters.
    --quiet (-q) # Does not print any messages when set.
  ] {
  makeConfWritable
  let substituters = readJson;
  if $all {
    restoreConf
    for $substituter in $substituters.key {
      main activate $substituter --quiet
    }
    if not $quiet { print "Activated all optional substituters." }
    return
  }
  mut conf = (open "${confPath}" --raw | into string)
  for $name in $names {
    let url = ($substituters | find -c [key] $name)
    if ($url | length) == 0 {
      if not $quiet { print -e $"Could not find substituter \"($name)\" in registry." }
    } else {
      let value = $url.0.value
      if ($conf | str contains $"extra-substituters = ($value)") {
        print $"Substituter \"($name)\" is already active."
      } else {
        $conf = ((($conf | str replace --all $"extra-substituters = ($value)" "") + $"\nextra-substituters = ($value)") | str trim)
        if not $quiet { print $"Activated substituter \"($name)\"." }
      }
    }
  }
  $conf | save --force "${confPath}"
}

# Allows you to deactivate an optional substituter.
def "main deactivate" [
    ...names: string, # The substituter or substituters to deactivate.
    --all (-a) # Deactivates all optional substituters.
    --quiet (-q) # Does not print any messages when set.
  ] {
  let substituters = readJson;
  if $all {
    restoreConf
    for $substituter in $substituters.key {
      main deactivate $substituter --quiet
    }
    if not $quiet { print "Deactivated all optional substituters." }
    return
  }
  makeConfWritable
  mut conf = (open "${confPath}" --raw | into string)
  for $name in $names {
    let url = ($substituters | find -c [key] $name)
    if ($url | length) == 0 {
      if not $quiet { print -e $"Could not find substituter \"($name)\" in registry." }
    } else {
      let value = $url.0.value
      if ($conf | str contains $"extra-substituters = ($value)") {
        $conf = ($conf | str replace --all $"extra-substituters = ($value)" "" | str trim)
        if not $quiet { print $"Deactivated substituter \"($name)\"." }
      } else {
        if not $quiet { print $"Substituter \"($name)\" is not currently active." }
      }
    }
  }
  $conf | save --force "${confPath}"
}

# Prints a list of all optional substituters and whether they're active or not.
def "main list" [
  --no-ping (-n) # Prevent this command from pinging the substituters to get their reachable status.
  --timeout (-t): int = 3 # Timeout in seconds for pinging the substituters.
] {
  let conf = (open "${confPath}" --raw | into string)
  let list = (readJson |
    insert state {|row| if ($conf | str contains $"extra-substituters = ($row.value)") { "active" } else { "inactive" }}
  );
  if $no_ping {
    return $list
  } else {
    return ($list | par-each {|row|
      # Basically, if /*  */the host is not in the ssh known_hosts this will automatically input no and report an error
      let ping = NIX_SSHOPTS="-oStrictHostKeyChecking=yes" ((${timeout} $"($timeout)s" "nix" "store" "ping" "--store" $row.value) | complete)
      if $ping.exit_code != 0 {
        if ($ping.stderr | str contains "interrupted by the user") or ($ping.stderr | str contains "timed out") {
          $row | insert remote "timed out"
        } else if ($ping.stderr | str contains "key verification failed") {
          $row | insert remote "key verification failed"
        } else {
          $row | insert remote "unreachable"
        }
      } else {
        $row | insert remote "reachable"
      }
    })
  }
}

def main [] {
  print "Missing a subcommand... Use the -h or --help argument to display a help message."
}
'';
in
{

  options = {
    gradient.substituters = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = {};
      example = { nixos = "https://cache.nixos.org"; };
      description = ''
        List of optional substituters to enable or disable with a command.
        Attribute name gets used as the alias on the command.
        Don't forget to add their public keys to `nix.settings.trusted-public-keys`
      '';
    };
  };

  config = {
    environment.etc."nix/substituter-switcher.conf".text = "";
    environment.etc."nix/substituter-switcher.json".text = builtins.toJSON cfg;
    environment.variables.NIX_USER_CONF_FILES = [ confPath ];
    environment.systemPackages = [ script ];
  };

}