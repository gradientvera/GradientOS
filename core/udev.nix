{ pkgs, ... }:
{

  powerManagement.scsiLinkPolicy = "max_performance";

  services.udev.extraRules = ''
    # -- I/O schedulers --
    # HDD
    ACTION=="add|change", KERNEL=="sd[a-z]*", ATTR{queue/rotational}=="1", \
        ATTR{queue/scheduler}="bfq"

    # SSD
    ACTION=="add|change", KERNEL=="sd[a-z]*|mmcblk[0-9]*", ATTR{queue/rotational}=="0", \
        ATTR{queue/scheduler}="mq-deadline"

    # NVMe SSD
    ACTION=="add|change", KERNEL=="nvme[0-9]*", ATTR{queue/rotational}=="0", \
        ATTR{queue/scheduler}="none"
    # -- #

    # HDD parameters
    ACTION=="add|change", KERNEL=="sd[a-z]", ATTR{queue/rotational}=="1", \
        ATTRS{id/bus}=="ata", RUN+="${pkgs.hdparm}/bin/hdparm -B 254 -S 0 /dev/%k"
  
    # -- Power --
    # Disable autosuspend for input USB devices
    ACTION=="add", SUBSYSTEM=="input", TEST=="power/control", ATTR{power/control}="on"
    ACTION=="add", SUBSYSTEM=="input", TEST=="power/autosuspend", ATTR{power/autosuspend}="-1"
    ACTION=="add", SUBSYSTEM=="input", TEST=="power/autosuspend_delay_ms", ATTR{power/autosuspend_delay_ms}="-1"
  '';

}