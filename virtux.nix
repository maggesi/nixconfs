/* ========================================================================= */
/* Configuration file for "virtux", virtualbox guest on "soyouz" MacBookPro  */
/* ========================================================================= */

{pkgs, config, ...}:

let
  useVirtualboxVideo = true;
  texLivePaths = with pkgs; [
    texLive texLiveExtra texLiveCMSuper
    texLiveBeamer lmodern texLiveContext
  ];
  myTexLive = pkgs.texLiveAggregationFun { paths = texLivePaths; };
in
{
  boot = {

    # The follwoing kernel params are needed when VirtualBox Guest
    # Additions do not work to set up a convenient screen size (see
    # also below in the configuration of xorg).
    extraKernelParams = ["vga=0x200 | 0x160" "vga=864"];

    loader.grub.device = "/dev/sda";
    initrd.kernelModules = [ "ata_piix" "fuse" ];
    initrd.enableSplashScreen = false;
    kernelPackages = pkgs.linuxPackages_2_6_35; # For BLCR
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
    virtualbox.enable = useVirtualboxVideo;

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

    } // (if useVirtualboxVideo then {
      videoDriver = "virtualbox";
    } else {
      videoDriver = "vesa";

      # The following configuration can be used to get a convenient
      # screen size when VirtualBox Guest Additions do not work.

      resolutions = [ { x=1680; y=1050; } { x=1440; y=900; }
                      { x=1280; y=1024; } { x=1152; y=864; }
                      { x=1024; y=768; } { x=800; y=600; } ];

      monitorSection = ''
        HorizSync 24.0-92.0
        VertRefresh 50.0-85.0
        Modeline "1440x900" 106.5000 1440 1520 1672 1904 900 903 909 934 +HSync -VSync
        Modeline "1680x1050" 188.1 1680 1800 1984 2288 1050 1051 1054 1096 +HSync -VSync
      '';
    });
  };

  environment = {
    #acpid.enable = true;
    blcr.enable = true;

    systemPackages =
      with pkgs;
      [
        emacs
        firefoxWrapper
        chromeWrapper
        screen
        mc
        adobeReader
        fossil
        subversion
	gitAndTools.gitFull
	gitAndTools.gitAnnex
        bup
      ];

    kdePackages = [] ++ (if useVirtualboxVideo then [
      config.boot.kernelPackages.virtualboxGuestAdditions
    ] else []);
  };

  security = {
    setuidPrograms = [ "reboot" "halt" ];
    sudo.enable = true;
  };

  nixpkgs.config = {
    git.guiSupport = true;
    git.svnSupport = true;
    subversion.perlBindings = true;
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
