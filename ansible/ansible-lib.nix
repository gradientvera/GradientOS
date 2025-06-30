{ lib
, pkgs
, nix-bundle
, runCommandNoCC
}:
rec
{

  ansibleBuiltinCopy = { src, dest, owner ? "root", group ? "root", mode ? "0440", name ? "Copy ${src} to ${dest} owned by ${owner}:${group} with mode ${mode}", ... }:
  {
    inherit name;
    "ansible.builtin.copy" = {
      inherit owner group mode;
      src = toString src;
      dest = toString dest;
    };
  };

  installPackageExe = attrs@{ pkg, dest, mode ? "0744", ... }: ansibleBuiltinCopy ({
    inherit mode;
    name = "Install ${lib.getName pkg} to ${dest}";
    src = lib.getExe pkg;
  } // attrs);
  
}