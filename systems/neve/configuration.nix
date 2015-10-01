### ===========================================================================
### Configuration file for "neve" ("nix" in italian ;-) (PC desktop).
### ===========================================================================

{ pkgs, config, ...}:

{
  require =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      # <nixos/modules/programs/virtualbox.nix>
    ];

  boot.initrd.kernelModules =
    [ # Specify all kernel modules that are necessary for mounting the root
      # filesystem.
      # "xfs" "ata_piix"
    ];

  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.device = "/dev/sda";

  # Needed for compatibility with the present version of BLCR
  boot.kernelPackages = pkgs.linuxPackages_3_14;

  hardware.enableAllFirmware = true;

  networking.hostName = "neve";

  networking.defaultMailServer.directDelivery = true;
  networking.defaultMailServer.hostName = "mail.math.unifi.it";
  networking.interfaces.enp3s0 = {
     ipAddress = "150.217.33.63";
     prefixLength = 24;
  };
  networking.defaultGateway = "150.217.33.1";
  networking.nameservers = [ "150.217.1.32" "8.8.8.8" "150.217.33.11" ];

  fileSystems = [ { mountPoint = "/"; label = "nixos"; } ];
  swapDevices = [ { label = "swap"; } ];

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

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver.layout = "us";
  services.xserver.xkbOptions = "eurosign:e";
  services.xserver.desktopManager.default = "xfce";

  services.xserver.desktopManager.kde4.enable = true;
  services.xserver.desktopManager.xfce.enable = true;

  services.locate.enable = true;
  services.locate.period = "40 3 * * *";

  services.gpm.enable = true;

  services.openafsClient.enable = true;
  services.openafsClient.cellName = "math.unifi.it";

  security.setuidPrograms = [ "reboot" "halt" ];

  powerManagement.enable = true;

  time.timeZone = "Europe/Rome";

  environment.blcr.enable = true;
  #environment.blcr.debug = true;

  environment.systemPackages = with pkgs; [ linuxPackages.perf ];

  nix.extraOptions = "auto-optimise-store = true";
  nix.gc.automatic = true;
  nix.gc.dates = "13:15";
  nix.gc.options = "--delete-older-than 60d";

  nixpkgs.config.allowUnfree = true;

  krb5 = {
    enable = true;
    defaultRealm = "MATH.UNIFI.IT";
    kdc = "kerberos.math.unifi.it";
    kerberosAdminServer = "kerberos.math.unifi.it";
  };

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
}
