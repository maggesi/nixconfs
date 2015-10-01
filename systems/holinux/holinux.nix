# Edit this configuration file which defines what would be installed on the
# system.  To Help while choosing option value, you can watch at the manual
# page of configuration.nix or at the last chapter of the manual available
# on the virtual console 8 (Alt+F8).

{config, pkgs, ...}:

{
  require = [ ./hardware-configuration.nix ];

  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.device = "/dev/sda";
  boot.kernelPackages = pkgs.linuxPackages_3_4;

  networking.hostName = "holinux";

  fileSystems = [ { mountPoint = "/"; label = "nixos"; } ];
  swapDevices = [ { label = "swap"; } ];

  # Select internationalisation properties.
  i18n.consoleFont = "lat9w-16";
  i18n.consoleKeyMap = "us";
  i18n.defaultLocale = "en_US.UTF-8";

  environment.blcr.enable = true;
  environment.systemPackages = [ pkgs.firefoxWrapper ];

  services.xserver.enable = true;
  services.xserver.layout = "us";
  services.xserver.xkbOptions = "eurosign:e";

  services.xserver.desktopManager.default = "xfce";
  services.xserver.desktopManager.xfce.enable = true;

  services.xserver.displayManager.auto.enable = true;
  services.xserver.displayManager.auto.user = "holuser";

  time.timeZone = "Europe/Rome";
}
