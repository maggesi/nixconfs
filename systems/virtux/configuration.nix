/* ========================================================================= */
/* Configuration file for "virtux", virtualbox guest on "soyouz" MacBookPro  */
/* ========================================================================= */

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  # Define on which hard drive you want to install Grub.
  boot.loader.grub.device = "/dev/sda";

  # Needed for compatibility with the present version of BLCR
  boot.kernelPackages = pkgs.linuxPackages_3_14;

  time.timeZone = "Europe/Rome";

  nix.extraOptions = "auto-optimise-store = true";

  # The follwoing kernel params are needed when VirtualBox Guest
  # Additions do not work to set up a convenient screen size (see
  # also below in the configuration of xorg).
  #boot.extraKernelParams = ["vga=0x200 | 0x160" "vga=864"];

  ### fileSystems = [ { label = "nixos"; mountPoint = "/"; } ];
  ### swapDevices = [ { label = "swap"; } ];

  time.timeZone = "Europe/Rome";

  networking.hostName = "virtux";
  networking.hostId = "04b63126";
  networking.defaultMailServer.directDelivery = true;
  networking.defaultMailServer.hostName = "mail.math.unifi.it";

  services = {
    gpm.enable = true;

    locate.enable = true;
    locate.period = "40 3 * * *";

    xserver = {
      enable = true;
      exportConfiguration = true;

      desktopManager = {
        default = "xfce";
        #default = "kde4";
        xfce.enable = true;
        kde4.enable = false;
      };
      displayManager.auto = { enable = true; user = "maggesi"; };

      driSupport = true;
    };
  };

  environment.blcr.enable = true;

  security = {
    setuidPrograms = [ "reboot" "halt" ];
    sudo.enable = true;
  };

  users.extraUsers = [
    { description = "Marco Maggesi";
      name = "maggesi";
      group = "users";
      extraGroups = [ "wheel"] ;
      useDefaultShell = true;
      home = "/home/maggesi";
      createHome = true;
    }
  ];

  powerManagement.enable = true;
}
