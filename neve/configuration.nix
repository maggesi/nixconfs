### ===========================================================================
### Configuration file for "neve" ("nix" in italian ;-) (PC desktop).
### ===========================================================================

{ pkgs, config, ...}:

let
  texLivePaths = with pkgs; [
    texLive texLiveExtra texLiveCMSuper
    texLiveBeamer lmodern texLiveContext
  ];
  myTexLive = pkgs.texLiveAggregationFun { paths = texLivePaths; };
in
{
  boot = {
    loader.grub.enable = true;
    loader.grub.device = "/dev/sdb3";
    #initrd.kernelModules = [];
    kernelPackages = pkgs.linuxPackages_2_6_35;
    #kernelPackages = pkgs.linuxPackages_2_6_32_xen;
    initrd.enableSplashScreen = false;
  };

  fileSystems = [
    { label = "nixos"; mountPoint = "/"; }
    { device = "/dev/sdb1"; mountPoint = "/mnt/ubuntu"; }
    { device = "/dev/sda1"; mountPoint = "/mnt/windows"; }
  ];

  swapDevices = [ { label = "swap"; } ];

  networking = {
    hostName = "neve";
    nameservers = [ "150.217.33.11" "150.217.1.32" ];
    defaultMailServer.directDelivery = true;
    defaultMailServer.hostName = "mail.math.unifi.it";
    /*
    useDHCP = false;
    interfaces = [ {
      name = "eth0";
      ipAddress = "150.217.33.145";
      subnetMask = "255.255.255.0";
    } ];
    defaultGateway = "150.217.33.1";
    */
  };

  environment = {
    systemPackages =
      with pkgs;
      [
        emacs
        firefoxWrapper
        chromeWrapper
        screen
        mc

        gnumake
        diffutils
        file
        patch
        which

        subversion
        gitAndTools.gitFull
        gitAndTools.gitAnnex
        #bup

        texmacs
        myTexLive

        # Science/logic
        coq
        cvc3
        eprover
        hol
        hol_light
        iprover
        isabelle
        leo2
        matita
        minisat
        opensmt
        prover9
        satallax
        spass

        # Science/math
        #pkgs.content
        maxima
        pari
        #pkgs.scilab
        singular
        wxmaxima
        yacas

        # OCaml
        ocamlPackages.ocaml
        ocamlPackages.findlib
        ocamlPackages.ounit
        ocamlPackages.camlp5_strict
      ];

/*
    kdePackages = with pkgs.kde4; [
      kdeadmin kdeartwork kdebindings kdeedu kdegraphics kdemultimedia
      kdenetwork kdepim
      kdeplasma_addons kdetoys kdeutils
    ];
*/

    blcr = {
      enable = true;
      autorun = true;
    };

  };

  nix = {
    maxJobs = 3;

    extraOptions = ''
      gc-keep-outputs = true
      gc-keep-derivations = true
    '';

    useChroot = false;
  };

  nixpkgs.config = {
    git.guiSupport = true;
    git.svnSupport = true;
    subversion.perlBindings = true;
    firefox = {
      enableRealPlayer = true;
      jre = true;
    };
  };

  powerManagement.enable = true;

  services = {
    acpid.enable = true;
    openssh.enable = true;
    # atd.enable = false;

    locate.enable = true;
    locate.period = "40 3 * * *";

    gpm.enable = true;
    printing.enable = true; # http://localhost:631/ per configurare.

    xserver = {
      enable = true;
      exportConfiguration = true;
      #desktopManager.default = "kde4";
      desktopManager.default = "xfce";
      desktopManager.kde4.enable = true;
      desktopManager.xfce.enable = true;
      driSupport = true;
    };

    openafsClient = {
      enable = true;
      cellName = "math.unifi.it";
    };

    ttyBackgrounds.enable = false;
  };

  security.setuidPrograms = [
    "reboot"
    "halt"
  ];
  time.timeZone = "Europe/Rome";

  krb5 = {
    enable = true;
    defaultRealm = "MATH.UNIFI.IT";
    kdc = "kerberos.math.unifi.it";
    kerberosAdminServer = "kerberos.math.unifi.it";
  };

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

  #virtualisation.xen.enable = true;
  #virtualisation.xen.domain0MemorySize = 640;
}
