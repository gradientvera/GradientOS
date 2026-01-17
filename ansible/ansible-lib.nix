{ lib
, pkgs
, openssh
, lixPackageSets
}:
rec {

  # See https://docs.ansible.com/ansible/latest/reference_appendices/playbooks_keywords.html#task
  # Only "action" is required, the rest are optional.
  # Because we're just returning the attribute set as is,
  # all of the "? null" values will be missing from it unless explicitly set.
  baseAnsibleTask = attrs@
  # The ‘action’ to execute for a task, it normally translates into a C(module) or action plugin.
  { action ? null
  # Identifier. Can be used for documentation, or in tasks/handlers.
  , name ? null
  # Force any un-handled task errors on any host to propagate to all hosts and end the play.
  , any_errors_fatal ? null
  # A secondary way to add arguments into a task. Takes a dictionary in which keys map to options and values.
  , args ? null
  # Run a task asynchronously if the C(action) supports this; the value is the maximum runtime in seconds.
  , async ? null
  # Boolean that controls if privilege escalation is used or not on Task execution. Implemented by the become plugin. See Become plugins.
  , become ? null
  # Path to the executable used to elevate privileges. Implemented by the become plugin. See Become plugins.
  , become_exe ? null
  # A string of flag(s) to pass to the privilege escalation program when become is True.
  , become_flags ? null
  # Which method of privilege escalation to use (such as sudo or su).
  , become_method ? null
  # User that you ‘become’ after using privilege escalation. The remote/login user must have permissions to become this user.
  , become_user ? null
  # Conditional expression that overrides the task’s normal ‘changed’ status.
  , changed_when ? null
  # A boolean that controls if a task is executed in ‘check’ mode. See Validating tasks: check mode and diff mode.
  , check_mode ? null
  # List of collection namespaces to search for modules, plugins, and roles. See Using collections in a playbook
  , collections ? null
  # Allows you to change the connection plugin used for tasks to execute on the target. See Using connection plugins.
  , connection ? null
  # Enable debugging tasks based on the state of the task result. See Debugging tasks.
  , debugger ? null
  # Number of seconds to delay between retries. This setting is only used in combination with until.
  , delay ? null
  # Boolean that allows you to apply facts to a delegated host instead of inventory_hostname.
  , delegate_facts ? null
  # Host to execute task instead of the target (inventory_hostname). Connection vars from the delegated host will also be used for the task.
  , delegate_to ? null
  # Toggle to make tasks return ‘diff’ information or not.
  , diff ? null
  # A dictionary that gets converted into environment vars to be provided for the task upon execution. This can ONLY be used with modules.
  # This is not supported for any other type of plugins nor Ansible itself nor its configuration, it just sets the variables for the code responsible for executing the task.
  # This is not a recommended way to pass in confidential data.
  , environment ? null
  # Conditional expression that overrides the task’s normal ‘failed’ status.
  , failed_when ? null
  # Boolean that allows you to ignore task failures and continue with play. It does not affect connection errors.
  , ignore_errors ? null
  # Boolean that allows you to ignore task failures due to an unreachable host and continue with the play. This does not affect other task errors (see ignore_errors) but is useful for groups of volatile/ephemeral hosts.
  , ignore_unreachable ? null
  # Same as action but also implies `delegate_to: localhost`
  , local_action ? null
  # Takes a list for the task to iterate over, saving each list element into the `item` variable (configurable via `loop_control`)
  , loop ? null
  # Several keys here allow you to modify/set loop behavior in a task. See Adding controls to loops. https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_loops.html#loop-control
  , loop_control ? null
  # Specifies default parameter values for modules.
  , module_defaults ? null
  # Boolean that controls information disclosure.
  , no_log ? null
  # List of handlers to notify when the task returns a ‘changed=True’ status.
  , notify ? null
  # Sets the polling interval in seconds for async tasks (default 10s).
  , poll ? null
  # Used to override the default port used in a connection.
  , port ? null
  # Name of variable that will contain task status and module return data.
  , register ? null
  # User used to log into the target via the connection plugin.
  , remote_user ? null
  # Number of retries before giving up in a until loop. This setting is only used in combination with until.
  , retries ? null
  # Boolean that will bypass the host loop, forcing the task to attempt to execute on the first host available and afterward apply any results and facts to all active hosts in the same batch.s
  , run_once ? null
  # Tags applied to the task or included tasks, this allows selecting subsets of tasks from the command line.
  , tags ? null
  # Limit the number of concurrent task runs on task, block and playbook level. This is independent of the forks and serial settings, but cannot be set higher than those limits.
  # For example, if forks is set to 10 and the throttle is set to 15, at most 10 hosts will be operated on in parallel.
  , throttle ? null
  # Time limit for the task action to execute in, if exceeded, Ansible will interrupt the process. Timeout does not include templating or looping.
  , timeout ? null
  # This keyword implies a ‘retries loop’ that will go on until the condition supplied here is met or we hit the retries limit. https://docs.ansible.com/ansible/latest/reference_appendices/playbooks_keywords.html#term-retries
  , until ? null
  # Dictionary/map of variables
  , vars ? null
  # Conditional expression, determines if an iteration of a task is run or not.
  , when ? null
  # The same as loop but magically adds the output of any lookup plugin to generate the item list.
  # with_<lookup_plugin>
  # See https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_blocks.html#grouping-tasks-with-blocks
  , block ? null
  # See https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_blocks.html#handling-errors-with-blocks
  , rescue ? null
  , ...
  }: attrs;

  mkAnsibleTask = { task, module }:
    (baseAnsibleTask task) // module;

  modules = {
    block = tasks: {
      block = tasks;
    };

    # See https://docs.ansible.com/ansible/latest/collections/ansible/builtin/copy_module.html#parameters
    ansibleBuiltinCopy = attrs@
    { dest
    , attributes ? null
    , backup ? null
    , checksum ? null
    , content ? null
    , decrypt ? null
    , directory_mode ? null
    , follow ? null
    , force ? null
    , group ? null
    , local_follow ? null
    , mode ? null
    , owner ? null
    , remote_src ? null
    , selevel ? null
    , serole ? null
    , setype ? null
    , seuser ? null
    , src ? null
    , unsafe_writes ? null
    , validate ? null
    , ... 
    }:
    {
      "ansible.builtin.copy" = attrs;
    };

    # See https://docs.ansible.com/ansible/latest/collections/ansible/builtin/file_module.html#parameters
    ansibleBuiltinFile = attrs@
    { path
    , access_time ? null
    , access_time_format ? null
    , attributes ? null
    , follow ? null
    , force ? null
    , group ? null
    , mode ? null
    , modification_time ? null
    , modification_time_format ? null
    , owner ? null
    , recurse ? null
    , selevel ? null
    , serole ? null
    , setype ? null
    , seuser ? null
    , src ? null
    , state ? null
    , unsafe_writes ? null 
    , ... }:
    {
      "ansible.builtin.file" = attrs;
    };

    # See https://docs.ansible.com/ansible/latest/collections/ansible/builtin/template_module.html#parameters
    ansibleBuiltinTemplate = attrs@
    { dest
    , src
    , attributes ? null
    , backup ? null
    , block_end_string ? null
    , block_start_string ? null
    , comment_end_string ? null
    , comment_start_string ? null
    , follow ? null
    , force ? null
    , group ? null
    , lstrip_blocks ? null
    , mode ? null
    , newline_sequence ? null
    , output_encoding ? null
    , owner ? null
    , selevel ? null
    , serole ? null
    , setype ? null
    , seuser ? null
    , trim_blocks ? null
    , unsafe_writes ? null
    , validate ? null
    , variable_end_string ? null
    , variable_start_string ? null
    , ... }:
    {
      "ansible.builtin.template" = attrs;
    };

    ansibleBuiltinCommand = command:
    {
      "ansible.builtin.command" = command;
    };

    # https://docs.ansible.com/ansible/latest/collections/ansible/builtin/stat_module.html
    ansibleBuiltinStat = attrs@
    { path
    , checksum_algorithm ? null
    , follow ? null
    , get_attributes ? null
    , get_checksum ? null
    , get_mime ? null
    , ...
    }:
    {
      "ansible.builtin.stat" = attrs;
    };

    ansibleBuiltinPip = attrs@
    { break_system_packages ? null
    , chdir ? null
    , editable ? null
    , executable ? null
    , extra_args ? null
    , name ? null
    , requirements ? null
    , state ? null
    , umask ? null
    , version ? null
    , virtualenv ? null
    , virtualenv_command ? null
    , virtualenv_python ? null
    , virtualenv_site_packages ? null
    , ...
    }:
    {
      "ansible.builtin.pip" = attrs;
    };

    communityGeneralOpkg = attrs@
    { name
    , executable ? null
    , force ? null
    , state ? null
    , update_cache ? null
    , ...
    }:
    {
      "community.general.opkg" = attrs;
    };
  };

  tasks = {
    block = taskArgs@{ ... }: tasks: mkAnsibleTask {
      task = taskArgs;
      module = modules.block tasks;
    };

    ansibleBuiltinCopy = taskArgs@{ ... }: moduleArgs@{ dest, ... }: mkAnsibleTask {
      task = taskArgs;
      module = modules.ansibleBuiltinCopy moduleArgs;
    };

    ansibleBuiltinFile = taskArgs@{ ... }: moduleArgs@{ path, ... }: mkAnsibleTask {
      task = taskArgs;
      module = modules.ansibleBuiltinFile moduleArgs;
    };

    ansibleBuiltinTemplate = taskArgs@{ ... }: moduleArgs@{ path, ... }: mkAnsibleTask {
      task = taskArgs;
      module = modules.ansibleBuiltinTemplate moduleArgs;
    };

    ansibleBuiltinCommand = taskArgs@{ ... }: command: mkAnsibleTask {
      task = taskArgs;
      module = modules.ansibleBuiltinCommand command;
    };

    ansibleBuiltinCommandLocal = taskArgs@{ ... }: command: mkAnsibleTask {
      task = { delegate_to = "127.0.0.1"; } // taskArgs;
      module = modules.ansibleBuiltinCommand command;
    };

    ansibleBuiltinStat = taskArgs@{ register, ... }: moduleArgs@{ path, ... }: mkAnsibleTask {
      task = {
        inherit register;
        name = "Retrieving facts for ${path}";
      } // taskArgs;
      module = modules.ansibleBuiltinStat moduleArgs;
    };

    installPackageExe = { pkg, dest, binPath ? null, taskArgs ? {}, moduleArgs ? {} }: mkAnsibleTask {
      task = {
        name = "Copy ${lib.getName pkg} binary built with Nix to ${dest}";
      } // taskArgs;
      module = modules.ansibleBuiltinCopy ({
        inherit dest;
        src = if binPath == null then lib.getExe pkg else "${pkg}${binPath}";
        owner = "root";
        group = "root";
        mode = "0744";
      } // moduleArgs);
    };

    nixCopyClosure = { pkg, remoteProgram ? "nix-store", taskArgs ? {} }: mkAnsibleTask {
      task = {
        name = "Copy closure of ${lib.getName pkg} to remote Nix store";
        delegate_to = "127.0.0.1";
        environment = {
          PATH = "${lixPackageSets.latest.lix}/bin:${openssh}/bin";
        };
      } // taskArgs;
      module = modules.ansibleBuiltinCommand "nix-copy-closure --quiet {{ ansible_user }}@{{ ansible_host }}?port={{ ansible_port }}&remote-program=${remoteProgram} ${pkg}";
    };

    nixAddRoot = { pkg, rootDest, taskArgs ? {} }: mkAnsibleTask {
      task = {
        name = "Add GC root for closure of ${lib.getName pkg}";
      } // taskArgs;
      module = modules.ansibleBuiltinCommand "nix-store --add-root ${rootDest}/${baseNameOf (toString pkg)} --realise ${pkg}";
    };

    nixCopyClosureWithRoot = { pkg, rootDest, remoteProgram ? "nix-store", taskArgs ? {} }: mkAnsibleTask {
      task = taskArgs;
      module = modules.block [
        (tasks.nixCopyClosure { inherit pkg remoteProgram; })
        (tasks.nixAddRoot { inherit pkg rootDest; })
      ];
    };

    nixMakeSymlinkToFile = { pkg, srcPath, destPath, taskArgs ? {}, moduleArgs ? {} }: 
      tasks.nixMakeSymlinkCustom { inherit pkg srcPath taskArgs moduleArgs; destPath = "${destPath}/${baseNameOf srcPath}"; };

    nixMakeSymlinkCustom = { pkg, srcPath, destPath, taskArgs ? {}, moduleArgs ? {} }: let
      filePath = "${pkg}${srcPath}";
    in mkAnsibleTask {
      task = {
        name = "Make symlink from ${destPath} to ${filePath}";
      } // taskArgs;
      module = modules.ansibleBuiltinFile ({
        path = destPath;
        src = filePath;
        state = "link";
      } // moduleArgs);
    };

    nixMakeSymlinkCustomGlibc = { pkg, glibc, srcPath, destPath, taskArgs ? {}, moduleArgs ? {} }: let
      filePath = "${pkg}${srcPath}";
    in mkAnsibleTask {
      task = {
        name = "Create glibc wrapper at ${destPath} to ${filePath}";
      } // taskArgs;
      module = modules.ansibleBuiltinCopy {
        dest = toString destPath;
        content = ''
          #!/bin/sh
          LD_LIBRARY_PATH="${toString glibc}/lib" ${filePath} "$@"
        '';
        owner = "root";
        group = "root";
        mode = "0554";
      };
    };

    nixMakeSymlinkToMainExe = { pkg, destPath, taskArgs ? {}, moduleArgs ? {} }: let
      pkgExe = lib.getExe pkg;
      pkgExeName = baseNameOf pkgExe;
    in
      tasks.nixMakeSymlinkCustom { inherit pkg taskArgs moduleArgs; srcPath = builtins.replaceStrings [ (toString pkg) ] [ "" ] pkgExe; destPath = "${destPath}/${baseNameOf pkgExeName}"; };

    nixMakeSymlinkToMainExeGlibc = { pkg, glibc, destPath, taskArgs ? {}, moduleArgs ? {} }: let
      pkgExe = lib.getExe pkg;
      pkgExeName = baseNameOf pkgExe;
    in
      tasks.nixMakeSymlinkCustomGlibc { inherit pkg glibc taskArgs moduleArgs; srcPath = builtins.replaceStrings [ (toString pkg) ] [ "" ] pkgExe; destPath = "${destPath}/${baseNameOf pkgExeName}"; };

    opkg = taskArgs@{ ... }: moduleArgs@{ name, ... }:
    let
      package = if builtins.isList name then builtins.concatStringsSep ", " name else toString name;
    in mkAnsibleTask
    {
      task = {
        name = if builtins.isList name then "Installing opkg packages ${package}" else "Installing opkg package ${package}";
      } // taskArgs;
      module = modules.communityGeneralOpkg moduleArgs;
    };

    pip = taskArgs@{ ... }: moduleArgs@{ name, ... }:
    let
      package = if builtins.isList name then builtins.concatStringsSep ", " name else toString name;
    in mkAnsibleTask {
      task = {
        name = if builtins.isList name then "Installing Python pip packages ${package}" else "Installing Python pip package ${package}";
      } // taskArgs;
      module = modules.ansibleBuiltinPip moduleArgs;
    };
  };
  
}