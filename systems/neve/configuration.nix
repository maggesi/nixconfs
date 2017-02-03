### ===========================================================================
### Configuration file for "neve" ("nix" in italian ;-) (PC desktop).
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

  hardware.enableAllFirmware = true;

  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  # Define on which hard drive you want to install Grub.
  boot.loader.grub.device = "/dev/sda";

  # Needed for compatibility with the present version of BLCR
  # boot.kernelPackages = pkgs.linuxPackages_3_14;
  boot.kernelPackages = custom_kernel.linuxPackages_3_14;

  powerManagement.enable = true;

  ## -------------------------------------------------------------------------
  ## Identity/hostname, networking and time.
  ## -------------------------------------------------------------------------

  networking.hostName = "neve";
  networking.hostId = "d40f5cff";
  # Workaround to fix the hostname pb "hostname -s"
  networking.extraHosts = "127.0.0.1 neve";
  networking.domain = "math.unifi.it";

  networking.interfaces.enp3s0 = {
     ipAddress = "150.217.33.63";
     prefixLength = 24;
  };
  networking.defaultGateway = "150.217.33.1";
  networking.nameservers =
    [ "150.217.33.1" "150.217.1.32" "8.8.8.8" "150.217.33.11" ];

  networking.defaultMailServer.directDelivery = true;
  networking.defaultMailServer.hostName = "mail.math.unifi.it";

  time.timeZone = "Europe/Rome";

  ## -------------------------------------------------------------------------
  ## Services
  ## -------------------------------------------------------------------------

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Enable CUPS to print documents.
  services.printing.enable = true;
  services.printing.drivers = [ pkgs.splix ];

  services.locate.enable = true;
  services.locate.interval = "4hours";

  services.cron.enable = true;
  services.cron.mailto = "marco.maggesi@gmail.com";
  services.cron.systemCronJobs =
    [ "37 12 * * * root obnam forget --config /root/.obnam.conf"
      "57 1-23/2 * * * root obnam backup --config /root/.obnam.conf"
    ];

  services.gpm.enable = true;

  services.openafsClient.enable = false;
  services.openafsClient.cellName = "math.unifi.it";

  services.ntp.enable = true;
  services.ntp.servers = [ "ntp.unifi.it" ];

  services.wakeonlan.interfaces =
    [ { interface = "eth0";
        method = "password";
        password = "13:05:19:71:31:41";
      }
    ];

  ## -------------------------------------------------------------------------
  ## X11 and desktop environment
  ## -------------------------------------------------------------------------

  services.xserver.enable = true;
  services.xserver.exportConfiguration = true;

  # services.xserver.layout = "us";
  # services.xserver.xkbOptions = "eurosign:e";

  services.xserver.desktopManager.default = "xfce";
  services.xserver.desktopManager.xfce.enable = true;
  services.xserver.desktopManager.kde4.enable = true;


  krb5 = {
    enable = true;
    defaultRealm = "MATH.UNIFI.IT";
    kdc = "kerberos.math.unifi.it";
    kerberosAdminServer = "kerberos.math.unifi.it";
  };

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

  nix.gc.automatic = true;
  nix.gc.dates = "13:15";
  nix.gc.options = "--delete-older-than 60d";

  nix.extraOptions = ''
      ssh-substituter-hosts = nix-ssh@elio.math.unifi.it
      auto-optimise-store = true
    '';

  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.firefox.enableAdobeFlash = true;
  nixpkgs.config.chromium.enableAdobeFlash = true;

}
