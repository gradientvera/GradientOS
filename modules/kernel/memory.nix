# Inspired by CryoUtilities' tweaks.
# See: https://github.com/CryoByte33/steam-deck-utilities/blob/db020c24bb74428b4f60d525e346ac6d2eb6f7b9/docs/tweak-explanation.md
{ config, lib, ... }:
let
  cfg = config.gradient;
in
{

  options = {
    gradient.kernel.transparent_hugepages.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Whether to enable transparent hugepages. Sets the policy to "always" by default.
        May require a reboot when disabling to restore the default values.
      '';
    };

    gradient.kernel.transparent_hugepages.policy = lib.mkOption {
      type = lib.types.enum [ "always" "madvise" "never" ];
      default = "always";
      description = ''
        The policy to use for transparent hugepages.
        May require a reboot when disabling to restore the default values.
      '';
    };

    gradient.kernel.transparent_hugepages.defrag = lib.mkOption {
      type = lib.types.enum [ "always" "defer" "defer+madvise" "madvise" "never" ];
      default = "defer+madvise";
      description = ''
        Whether to enable defragmentation.
        Does nothing if transparent hugepages is disabled.
      '';
    };

    gradient.kernel.transparent_hugepages.khugepaged.defrag = lib.mkOption {
      type = lib.types.enum [ "0" "1" ];
      default = "0";
      description = ''
        Whether to enable khugepaged defragmentation.
        Does nothing if transparent hugepages is disabled.
      '';
    };

    gradient.kernel.transparent_hugepages.max_ptes_none = lib.mkOption {
      type = lib.types.int;
      default = 409;
      description = ''
        Specifies how many extra small pages (that are not already mapped)
        can be allocated when collapsing a group of small pages into one large page
      '';
    };

    gradient.kernel.transparent_hugepages.sharedMemory = lib.mkOption {
      type = lib.types.enum [ "always" "within_size" "advise" "never" "deny" "force" ];
      default = "advise";
      description = ''
        Determines the transparent hugepage allocation policy for the internal shmem mount.
        Must be one of the following values: "always" "within_size" "advise" "never" "deny" "force"
        Does nothing if transparent hugepages is disabled.
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
    (lib.mkIf cfg.kernel.transparent_hugepages.enable {
      boot.kernel.sysfs = {
        kernel.mm.transparent_hugepage = {
          enable = cfg.kernel.transparent_hugepages.policy;
          defrag = cfg.kernel.transparent_hugepages.defrag;
          khugepaged.defrag = cfg.kernel.transparent_hugepages.khugepaged.defrag;
          khugepaged.max_ptes_none = cfg.kernel.transparent_hugepages.max_ptes_none;
          shmem_enabled = cfg.kernel.transparent_hugepages.sharedMemory;
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