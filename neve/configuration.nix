### ===========================================================================
### Configuration file for "neve" ("nix" in italian ;-) (PC desktop).
### ===========================================================================

{ pkgs, config, ...}:

{
  require =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      <nixos/modules/programs/virtualbox.nix>
    ];

  boot.initrd.kernelModules =
    [ # Specify all kernel modules that are necessary for mounting the root
      # filesystem.
      # "xfs" "ata_piix"
    ];

  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;

  # Define on which hard drive you want to install Grub.
  boot.loader.grub.device = "/dev/sda";

  #boot.kernelPackages = pkgs.linuxPackages_2_6_35;
  boot.initrd.enableSplashScreen = false;

  #hardware.enableAllFirmware = true;

  networking.hostName = "neve"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables Wireless.

  networking.defaultMailServer.directDelivery = true;
  networking.defaultMailServer.hostName = "mail.math.unifi.it";
  networking.interfaces.enp3s0 = {
     ipAddress = "150.217.33.63";
     prefixLength = 24;
  };
  networking.defaultGateway = "150.217.33.1";
  networking.nameservers = [ "8.8.8.8" "150.217.33.11" ];

  # Add filesystem entries for each partition that you want to see
  # mounted at boot time.  This should include at least the root
  # filesystem.
  fileSystems =
    [ { mountPoint = "/";
	    label = "nixos";
        #device = "/dev/disk/by-label/nixos";
      }
    ];

  # List swap partitions activated at boot time.
  swapDevices =
    [ {
	    #device = "/dev/disk/by-label/swap";
	    label = "swap";
	  }
    ];

  # Select internationalisation properties.
  i18n = {
    consoleFont = "lat9w-16";
    consoleKeyMap = "us";
    defaultLocale = "en_US.UTF-8";
  };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Enable CUPS to print documents.
  services.printing.enable = true;
  services.printing.drivers = [ pkgs.splix ];

  services.ttyBackgrounds.enable = false;

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver.layout = "us";
  services.xserver.xkbOptions = "eurosign:e";

  # X11 non funziona, proviamo ad aggiungere qualche conf.
  #services.xserver.desktopManager.default = "kde4";
  services.xserver.desktopManager.default = "xfce";

  # Enable the KDE Desktop Environment.
  # services.xserver.displayManager.kdm.enable = true;
  services.xserver.desktopManager.kde4.enable = true;
  services.xserver.desktopManager.xfce.enable = true;

  services.locate.enable = true;
  services.locate.period = "40 3 * * *";

  services.gpm.enable = true;

  #services.openafsClient.enable = true;
  #services.openafsClient.cellName = "math.unifi.it";

  security.setuidPrograms = [ "reboot" "halt" ];

  powerManagement.enable = true;

  time.timeZone = "Europe/Rome";

  environment.blcr.enable = true;

  /*
  krb5 = {
    enable = true;
    defaultRealm = "MATH.UNIFI.IT";
    kdc = "kerberos.math.unifi.it";
    kerberosAdminServer = "kerberos.math.unifi.it";
  };
  */

  /*
  users.extraUsers = [
    {
      name = "maggesi";
      description = "Marco Maggesi";
      home = "/home/maggesi";
      group = "users";
      extraGroups = [ "wheel" ];
      createHome = true;
      useDefaultShell = true;
    }
  ];
  */

  #virtualisation.xen.enable = true;
  #virtualisation.xen.domain0MemorySize = 640;
}
