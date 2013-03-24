/* ========================================================================= */
/* Configuration file for "virtux", virtualbox guest on "soyouz" MacBookPro  */
/* ========================================================================= */

{pkgs, config, ...}:

{
  boot = {
    # The follwoing kernel params are needed when VirtualBox Guest
    # Additions do not work to set up a convenient screen size (see
    # also below in the configuration of xorg).
    #extraKernelParams = ["vga=0x200 | 0x160" "vga=864"];

    loader.grub.device = "/dev/sda";
    initrd.kernelModules = [ "ata_piix" "fuse" ];
    initrd.enableSplashScreen = false;
    #kernelPackages = pkgs.linuxPackages_2_6_35; # For BLCR 0.8.4
  };

  fileSystems = [ { label = "nixos"; mountPoint = "/"; } ];
  swapDevices = [ { label = "swap"; } ];

  time.timeZone = "Europe/Rome";

  networking = {
    hostName = "virtux";
    defaultMailServer.directDelivery = true;
    defaultMailServer.hostName = "mail.math.unifi.it";
  };

  nix.maxJobs = 1;

  services = {
    virtualbox.enable = true;

    gpm.enable = true;
    ttyBackgrounds.enable = false;

    locate.enable = true;
    locate.period = "40 3 * * *";

    # postgresql.enable = true;
    # openssh.enable = false;
    # atd.enable = false;

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
