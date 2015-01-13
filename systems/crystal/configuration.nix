# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

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
  #boot.kernelPackages = pkgs.linuxPackages_3_4;

  environment.blcr.enable = true;

  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.firefox.enableAdobeFlash = true;
  nixpkgs.config.chromium.enableAdobeFlash = true;

  networking.hostName = "crystal"; # Define your hostname.
  networking.wireless.enable = true;  # Enables wireless.

  # Select internationalisation properties.
  # i18n = {
  #   consoleFont = "lat9w-16";
  #   consoleKeyMap = "us";
  #   defaultLocale = "en_US.UTF-8";
  # };

  # List packages installed in system profile. To search by name, run:
  # -env -qaP | grep wget
  # environment.systemPackages = with pkgs; [
  #   wget
  # ];

  # List services that you want to enable:

  security.setuidPrograms = [ "reboot" "halt" ];
  #security.sudo.enable = true;

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  # services.xserver.layout = "us";
  # services.xserver.xkbOptions = "eurosign:e";

  # Enable the KDE Desktop Environment.
  # services.xserver.displayManager.kdm.enable = true;
  # services.xserver.desktopManager.kde4.enable = true;

  # Enable xfce with auto login.
  services.xserver.displayManager.auto.enable = true;
  services.xserver.displayManager.auto.user = "maggesi";
  services.xserver.desktopManager.xfce.enable = true;

  time.timeZone = "Europe/Rome";

  #services.openafsClient.enable = true;
  #services.openafsClient.cellName = "math.unifi.it";

  #krb5.enable = true;
  #krb5.defaultRealm = "MATH.UNIFI.IT";
  #krb5.kdc = "kerberos.math.unifi.it";
  #krb5.kerberosAdminServer = "kerberos.math.unifi.it";

}
