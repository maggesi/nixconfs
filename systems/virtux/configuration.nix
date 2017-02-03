### ===========================================================================
### Configuration file for "virtux", virtualbox guest on "soyouz" MacBookPro
### ===========================================================================

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

  ## -------------------------------------------------------------------------
  ## Hardware, kernel, boot, power management and time.
  ## -------------------------------------------------------------------------

  require =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  # Define on which hard drive you want to install Grub.
  boot.loader.grub.device = "/dev/sda";

  # Needed for compatibility with the present version of BLCR
  # boot.kernelPackages = pkgs.linuxPackages_3_14;
  boot.kernelPackages = custom_kernel.linuxPackages_3_14;

  powerManagement.enable = true;

  # The follwoing kernel params are needed when VirtualBox Guest
  # Additions do not work to set up a convenient screen size (see
  # also below in the configuration of xorg).
  #boot.extraKernelParams = ["vga=0x200 | 0x160" "vga=864"];

  ## -------------------------------------------------------------------------
  ## Identity/hostname, networking and time.
  ## -------------------------------------------------------------------------

  networking.hostName = "virtux";
  networking.hostId = "04b63126";
  # Workaround to fix the hostname pb "hostname -s"
  networking.extraHosts = "127.0.0.1 virtux";
  # networking.wireless.enable = true;

  networking.defaultMailServer.directDelivery = true;
  networking.defaultMailServer.hostName = "mail.math.unifi.it";

  time.timeZone = "Europe/Rome";

  ## -------------------------------------------------------------------------
  ## Services
  ## -------------------------------------------------------------------------

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  # environment.systemPackages = with pkgs; [
  #   wget
  # ];

  # services.locate.enable = true;
  # services.locate.period = "40 3 * * *";

  # services.gpm.enable = true;

  ## -------------------------------------------------------------------------
  ## X11 and desktop environment
  ## -------------------------------------------------------------------------

  services.xserver.enable = true;
  services.xserver.exportConfiguration = true;

  # 2016-07-17: Workaround for VirtuabBox bug
  services.xserver.videoDrivers = lib.mkOverride 50 [ "virtualbox" "modesetting" ];

  # services.xserver.layout = "us";
  # services.xserver.xkbOptions = "eurosign:e";

  # Enable the KDE Desktop Environment.
  # services.xserver.displayManager.kdm.enable = true;
  # services.xserver.desktopManager.kde4.enable = true;

  # Enable the XFCE Desktop Environment.
  services.xserver.desktopManager.default = "xfce";
  services.xserver.desktopManager.xfce.enable = true;

  # Enable Display Manager.
  services.xserver.displayManager.auto.enable = true;
  services.xserver.displayManager.auto.user = "maggesi";

  services.xserver.driSupport = true;

  ## -------------------------------------------------------------------------
  ## Users and security
  ## -------------------------------------------------------------------------

  security.setuidPrograms = [ "reboot" "halt" ];
  security.sudo.enable = true;

  users.extraUsers = [
    { description = "Marco Maggesi";
      name = "maggesi";
      group = "users";
      extraGroups = [ "wheel" ];
      useDefaultShell = true;
      home = "/home/maggesi";
      createHome = true;
    }
  ];

  nix.trustedUsers = [ "root" "maggesi" "@wheel" ];

  ## -------------------------------------------------------------------------
  ## Environment
  ## -------------------------------------------------------------------------

  environment.systemPackages =
    with pkgs;
      [ linuxPackages.perf
        obnam
	emacs
      ];

  environment.blcr.enable = true;
  #environment.blcr.debug = true;

  ## -------------------------------------------------------------------------
  ## Nix/NixOS specific configs.
  ## -------------------------------------------------------------------------

  nix.extraOptions = ''
      ssh-substituter-hosts = nix-ssh@elio.math.unifi.it
      auto-optimise-store = true
    '';

  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.firefox.enableAdobeFlash = true;
  nixpkgs.config.chromium.enableAdobeFlash = true;

}
