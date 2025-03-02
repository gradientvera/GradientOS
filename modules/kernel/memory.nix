# Inspired by CryoUtilities' tweaks.
# See: https://github.com/CryoByte33/steam-deck-utilities/blob/db020c24bb74428b4f60d525e346ac6d2eb6f7b9/docs/tweak-explanation.md
{ config, lib, ... }:
let
  cfg = config.gradient;
in
{

  options = {
    gradient.kernel.hugepages.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Whether to enable hugepages. Sets the policy to "always".
        May require a reboot when disabling to restore the default values.
      '';
    };

    gradient.kernel.hugepages.defrag = lib.mkOption {
      type = lib.types.enum [ "0" "1" ];
      default = "0";
      description = ''
        Whether to enable khugepaged defragmentation. "0" to disable, "1" to enable.
        Does nothing if hugepages is disabled.
      '';
    };

    gradient.kernel.hugepages.sharedMemory = lib.mkOption {
      type = lib.types.enum [ "always" "within_size" "advise" "never" "deny" "force" ];
      default = "advise";
      description = ''
        Determines the hugepage allocation policy for the internal shmem mount.
        Must be one of the following values: "always" "within_size" "advise" "never" "deny" "force"
        Does nothing if hugepages is disabled.
      '';
    };

    gradient.kernel.swappiness = lib.mkOption {
      type = lib.types.nullOr (lib.types.numbers.between 0 100);
      default = null;
      description = ''
        Value to set swappiness to. Must be null for the default value, or a numerical value between 0 and 100.
        Determines how aggressively the kernel swaps out memory. Higher values means more swapping.
      '';
    };

    gradient.kernel.compactionProactiveness = lib.mkOption {
      type = lib.types.nullOr (lib.types.numbers.between 0 100);
      default = null;
      description = ''
        Value to set compaction proactivness to. Must be null for the default value, or a numerical value between 0 and 100.
        Determines how aggressive memory compaction is done in the background. Higher values means more compaction, 0 disables it entirely.
      '';
    };

    gradient.kernel.pageLockUnfairness = lib.mkOption {
      type = lib.types.nullOr (lib.types.numbers.between 1 10);
      default = null;
      description = ''
        Must be null for the default value, or a numerical value.
        Determines the number of times that the page lock can be stolen from under a waiter before "fair" behavior kicks in.
      '';
    };
    
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.kernel.hugepages.enable {
      systemd.tmpfiles.settings."10-gradientos-hugepages.conf" = {
        "/sys/kernel/mm/transparent_hugepage/enabled".w = {
          argument = "always";
        };
        "/sys/kernel/mm/transparent_hugepage/khugepaged/defrag".w = {
          argument = cfg.kernel.hugepages.defrag;
        };
        "/sys/kernel/mm/transparent_hugepage/shmem_enabled".w = {
          argument = cfg.kernel.hugepages.sharedMemory;
        };
      };
    })

    (lib.mkIf (cfg.kernel.swappiness != null) {
      boot.kernel.sysctl."vm.swappiness" = cfg.kernel.swappiness;
    })

    (lib.mkIf (cfg.kernel.compactionProactiveness != null) {
      boot.kernel.sysctl."vm.compaction_proactiveness" = cfg.kernel.compactionProactiveness;
    })

    (lib.mkIf (cfg.kernel.pageLockUnfairness != null) {
      boot.kernel.sysctl."vm.page_lock_unfairness" = cfg.kernel.pageLockUnfairness;
    })
    ];

}