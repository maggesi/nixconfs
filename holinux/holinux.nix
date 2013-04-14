# Edit this configuration file which defines what would be installed on the
# system.  To Help while choosing option value, you can watch at the manual
# page of configuration.nix or at the last chapter of the manual available
# on the virtual console 8 (Alt+F8).

{config, pkgs, ...}:

{
  require = [
    # Include the configuration for part of your system which have been
    # detected automatically.
    ./hardware-configuration.nix
  ];

  # boot.kernelPackages = pkgs.linuxPackages_2_6_35;

  boot.initrd.kernelModules = [
    # Specify all kernel modules that are necessary for mounting the root
    # file system.
    #
    # "ext4" "ata_piix"
  ];

  boot.loader.grub = {
    # Use grub 2 as boot loader.
    enable = true;
    version = 2;

    # Define on which hard drive you want to install Grub.
    device = "/dev/sda";
  };

  boot.vesa = true;

  networking = {
    hostName = "holinux"; # Define your hostname.
    # wireless.enable = true;  # Enables Wireless.
  };

  # Add file system entries for each partition that you want to see mounted
  # at boot time.  You can add filesystems which are not mounted at boot by
  # adding the noauto option.
  fileSystems = [
    # Mount the root file system
    #
    # { mountPoint = "/";
    #   device = "/dev/sda2";
    # }
    { mountPoint = "/";
      label = "nixos"; 
    }

    # Copy & Paste & Uncomment & Modify to add any other file system.
    #
    # { mountPoint = "/data"; # where you want to mount the device
    #   device = "/dev/sdb"; # the device or the label of the device
    #   # label = "data";
    #   fsType = "ext3";      # the type of the partition.
    #   options = "data=journal";
    # }
  ];

  swapDevices = [
    # List swap partitions that are mounted at boot time.
    #
    # { device = "/dev/sda1"; }
    { label = "swap"; }
  ];

  # Select internationalisation properties.
  i18n = {
    consoleFont = "lat9w-16";
    consoleKeyMap = "us";
    defaultLocale = "en_US.UTF-8";
  };

  environment.blcr.enable = true;

  environment.systemPackages = [
    pkgs.firefoxWrapper
    pkgs.emacs
    pkgs.hol_light
    pkgs.fossil
  ];

  # List services that you want to enable:

  # Add an OpenSSH daemon.
  # services.openssh.enable = true;

  # Add CUPS to print documents.
  # services.printing.enable = true;

  services.ttyBackgrounds.enable = false;

  # Add XServer (default if you have used a graphical iso)
  services.xserver = {
    enable = true;
    layout = "us";
    xkbOptions = "eurosign:e";

    ## windowManager.default = "awesome";
    ## windowManager.default = "i3";
    ## windowManager.default = "icewm";
    ## windowManager.default = "wmii";
    ## windowManager.awesome.enable = true;
    ## windowManager.i3.enable = true;
    ## windowManager.icewm.enable = true;
    ## windowManager.wmii.enable = true;

    desktopManager = {
      #default = "xfce";
      default = "kde4";
      xfce.enable = false;
      kde4.enable = true;
    };
    displayManager.auto = { enable = true; user = "holuser"; };
  };

  time.timeZone = "Europe/Rome";

  # Add the NixOS Manual on virtual console 8
  # services.nixosManual.showManual = true;
}
