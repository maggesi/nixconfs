# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

let

  custom_kernel = with pkgs; rec {

    linux_3_14 = callPackage ../../pkgs/linux/linux-3.14.nix {
      kernelPatches = [ kernelPatches.bridge_stp_helper ]
        ++ lib.optionals ((platform.kernelArch or null) == "mips")
        [ kernelPatches.mips_fpureg_emu
          kernelPatches.mips_fpu_sigill
          kernelPatches.mips_ext3_n32
        ];
    };

    linuxPackages_3_14 =
      recurseIntoAttrs (linuxPackagesFor linux_3_14 linuxPackages_3_14);
  };

in {

imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  # Define on which hard drive you want to install Grub.
  boot.loader.grub.device = "/dev/sda";

  # Needed for compatibility with BLCR 0.8.6
  # boot.kernelPackages = pkgs.linuxPackages_3_14;
  boot.kernelPackages = custom_kernel.linuxPackages_3_14;

  networking.hostName = "holbox"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.extraHosts = "127.0.0.1 holbox";

  # Select internationalisation properties.
  i18n = {
    #consoleFont = "Lat2-Terminus16";
    # consoleKeyMap = "us";
    consoleKeyMap = "it";
    #defaultLocale = "en_US.UTF-8";
  };

  # Set your time zone.
  time.timeZone = "Europe/Rome";

  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = with pkgs; [
    # emacs
  ];

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver.layout = "it";
  # services.xserver.xkbOptions = "eurosign:e";

  # Enable the KDE Desktop Environment.
  # services.xserver.displayManager.kdm.enable = true;
  # services.xserver.desktopManager.kde4.enable = true;
  services.xserver.displayManager.auto.enable = true;
  services.xserver.displayManager.auto.user = "holuser";
  services.xserver.desktopManager.xfce.enable = true;
  services.xserver.desktopManager.default = "xfce";

  environment.blcr.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.extraUsers.holuser = {
    isNormalUser = true;
    uid = 1000;
  };

  # The NixOS release to be compatible with for stateful data such as databases.
  #system.stateVersion = "15.09";

}
