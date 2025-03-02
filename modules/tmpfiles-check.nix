/* 
*
* Module that introduces a "doCheck" setting to tmpfiles.d, checks contents of C-type rules against their argument file.
* 
* USAGE:
*   Use "systemd.tmpfiles.settings.<package>.<path>.C" to declare your files.
*   Set "doCheck = true;" in the attribute.
*   File contents will be checked against the original on system activation.
*   If the files' hashes differ, it will print a warning.
*
*   You can also use the "tmpfiles-check" command to check existing files and create missing ones.
*   If you want to restore a file to its original contents, you can simply delete the file and run "tmpfiles-check".
*
*   To restore every single checked file to their original contents, you can run "tmpfiles-check-restore".
*   You can pass "-y" as an argument to skip the confirmation check. It takes no other arguments and has no help command, sorry!
*
*   To synchronize every single modified checked file to their specified repository paths, you can run "tmpfiles-check-sync".
*   You can also pass "-y" as an argument here, to skip the confirmation check. No other arguments yet, no help argument either!
*
* EXAMPLE:

systemd.tmpfiles.settings."example"."/home/vera/example.txt".C = {
  user = "vera";
  group = "users";
  mode = "0755";
  argument = "${pkgs.writeText "example.txt" ''Hello there!''}";
  repoPath = "/etc/nixos/example.txt";  # <- Optionally set this to make tmpfiles-check-sync work. 
  doCheck = true;   # <- This right here is the important bit!
};

*
*/
{ config, lib, pkgs, ... }:

with lib;

let
  tmpfiles-settings = config.systemd.tmpfiles.settings;
  filterFileAttrs = 
    (files:
      attrsets.filterAttrs
        (_: v:
          v ? C && v.C.doCheck
        )
        files
    );
  settingsToListOfStrings = 
    (mkScript: settings:
      (attrsets.mapAttrsToList
        (_: files:
          (builtins.concatStringsSep
            "\n"
            (attrsets.mapAttrsToList
              mkScript
              (filterFileAttrs files)
            )
          )
        )
        settings
      )
    );
  makeScriptFromSettings = 
    (mkScript:
      builtins.concatStringsSep 
      "\n"
      (settingsToListOfStrings mkScript tmpfiles-settings)
    );
  checkScriptFromFileSetting = 
    (target: args:
      let source = args.C.argument; in
      ''
        RED="\033[0;31m"
        PURPLE="\033[1;35m"
        NC="\033[0m"

        if [ -d "${target}" ]; then
          echo -e "''${RED}tmpfiles-check:$NC Target path ''${PURPLE}file://${target}$NC for source path ''${PURPLE}file://${source}$NC appears to be a directory. This is not supported."
        elif [ -d "${source}" ]; then
          echo -e "''${RED}tmpfiles-check:$NC Source path ''${PURPLE}file://${source}$NC for target path ''${PURPLE}file://${target}$NC appears to be a directory. This is not supported."
        elif [ -f "${target}" ] && [ -f "${source}" ]; then
          TARGET=($(${pkgs.coreutils}/bin/sha256sum "${target}" -b))
          SOURCE=($(${pkgs.coreutils}/bin/sha256sum "${source}" -b))

          if [ "$TARGET" != "$SOURCE" ]; then
            echo -e "''${RED}tmpfiles-check:$NC ''${PURPLE}file://${target}$NC differs from source at ''${PURPLE}file://${source}$NC"
          fi
        elif [ ! -f "${source}" ]; then
          echo -e "''${RED}tmpfiles-check:$NC Source file ''${PURPLE}file://${source}$NC for target path ''${PURPLE}file://${target}$NC does not exist."
        elif [ ! -f "${target}" ]; then
          ${pkgs.systemd}/bin/systemd-tmpfiles --create --prefix="${target}" && echo -e "''${RED}tmpfiles-check:$NC file://${target} created."
        fi
      ''
    );
  checkScript = makeScriptFromSettings checkScriptFromFileSetting;
  restoreScriptFromFileSetting=
    (target: args:
      let source = args.C.argument; in
      ''
        if [ -f "${target}" ] && [ -f "${source}" ]; then
          TARGET=($(${pkgs.coreutils}/bin/sha256sum "${target}" -b))
          SOURCE=($(${pkgs.coreutils}/bin/sha256sum "${source}" -b))
          if [ "$TARGET" != "$SOURCE" ]; then
            ${pkgs.coreutils}/bin/rm -f "${target}"
            ${pkgs.systemd}/bin/systemd-tmpfiles --create --prefix="${target}"
            echo -e "''${RED}->$NC file://${target}"
          fi
        elif [ ! -f "${source}" ]; then
          echo -e "''${RED}-X$NC Source file ''${PURPLE}file://${source}$NC for target path ''${PURPLE}file://${target}$NC does not exist."
        elif [ -d "${source}" ]; then
          echo -e "''${RED}-X$NC Source path ''${PURPLE}file://${source}$NC for target path ''${PURPLE}file://${target}$NC appears to be a directory. This is not supported."
        elif [ -d "${target}" ]; then
          echo -e "''${RED}-X$NC Target path ''${PURPLE}file://${target}$NC for source path ''${PURPLE}file://${source}$NC appears to be a directory. Please delete it manually and re-run this command."
        else
          ${pkgs.systemd}/bin/systemd-tmpfiles --create --prefix="${target}"
          echo -e "''${RED}->$NC file://${target}"
        fi
      ''
    );
    restoreScript = ''
      RED="\033[0;31m"
      PURPLE="\033[1;35m"
      NC="\033[0m"
      if [ "$1" != "-y" ]; then
        echo -e  "''${RED}warning:$NC This will overwrite all your checked files with their original contents.\n''${RED}Your changes will be lost.$NC"
        read -p "Are you sure you want to continue? " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            [[ "$0" = "$BASH_SOURCE" ]] && exit 1 || return 1
        fi
      fi

      echo "Restoring checked files..."
      ${(makeScriptFromSettings restoreScriptFromFileSetting)}
      echo "Done!"
    '';
    syncScriptFromFileSetting=
      (source: args: # Notice how "source" is now called "target" in the other scripts!
        let
          target = args.C.repoPath;
        in if target != null then
        ''
          if [ -f "${target}" ] && [ -f "${source}" ]; then
            TARGET=($(${pkgs.coreutils}/bin/sha256sum "${target}" -b))
            SOURCE=($(${pkgs.coreutils}/bin/sha256sum "${source}" -b))
            if [ "$TARGET" != "$SOURCE" ]; then
              ${pkgs.coreutils}/bin/cp "${source}" "${target}"
              echo -e "''${RED}->$NC file://${target}"
            fi
          elif [ ! -f "${source}" ]; then
            echo -e "''${RED}-X$NC Source file ''${PURPLE}file://${source}$NC for target path ''${PURPLE}file://${target}$NC does not exist."
          elif [ -d "${source}" ]; then
            echo -e "''${RED}-X$NC Source path ''${PURPLE}file://${source}$NC for target path ''${PURPLE}file://${target}$NC appears to be a directory. This is not supported."
          elif [ -d "${target}" ]; then
            echo -e "''${RED}-X$NC Target path ''${PURPLE}file://${target}$NC for source path ''${PURPLE}file://${source}$NC appears to be a directory. Please delete it manually and re-run this command."
          fi
        '' else "");
    syncScript = ''
      RED="\033[0;31m"
      PURPLE="\033[1;35m"
      NC="\033[0m"
      if [ "$1" != "-y" ]; then
        echo -e  "''${RED}warning:$NC This will overwrite the repository paths you specified with their modified counterparts.\n''${RED}Any changes will be lost.$NC"
        read -p "Are you sure you want to continue? " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            [[ "$0" = "$BASH_SOURCE" ]] && exit 1 || return 1
        fi
      fi

      echo "Synchronizing modified files to repository paths..."
      ${(makeScriptFromSettings syncScriptFromFileSetting)}
      echo "Done!"
    '';
in
{

  options.systemd.tmpfiles.settings = mkOption {
    type = types.attrsOf (types.attrsOf (types.attrsOf (types.submodule ({ name, config, ... }:
    {
      options.doCheck = mkOption {
        type = types.bool;
        default = false;
        example = true;
        description = mdDoc ''
          Whether to check if the target file hash differs from the source file hash specified in the argument.

          Only works with type of operation "C".
        '';
      };

      options.repoPath = mkOption {
        type = types.nullOr types.str;
        default = null;
        example = "/etc/nixos/example.conf";
        description = mdDoc ''
          Setting this allows you to write any changes from modified files back to your repository.
          Must be set to
        '';
      };
    }))));
  };

  config = {

    system.activationScripts = {
      tmpfiles-check.text = checkScript;
    };

    environment.systemPackages = [
      (pkgs.writeShellScriptBin "tmpfiles-check" checkScript)
      (pkgs.writeShellScriptBin "tmpfiles-check-restore" restoreScript)
      (pkgs.writeShellScriptBin "tmpfiles-check-sync" syncScript)
    ];

  };

}