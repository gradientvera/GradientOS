{ ... }:
{

  boot.blacklistedKernelModules = [
    # Fix wireless Logitech mouse disconnects
    "hid_logitech_dj"
  ];

}