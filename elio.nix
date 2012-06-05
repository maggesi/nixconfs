{ config, pkgs, modulesPath, ... }:

{
  require = [
    #"${modulesPath}/virtualisation/xen-domU.nix"
  ];

  boot.loader.grub = {
    enable = true;
    version = 2;
    device = "/dev/xvda";
  };

  #boot.kernelPackages = pkgs.linuxPackages_3_2_xen;

  fileSystems = [ { mountPoint = "/"; label = "nixos"; } ];
  swapDevices = [ { device = "/dev/xvda1"; } ];

  networking = {
    hostName = "elio";
    domain = "math.unifi.it";
    nameservers = [ "150.217.34.129" "150.217.34.211" ];
    defaultMailServer.directDelivery = true;
    defaultMailServer.hostName = "mail.math.unifi.it";

    useDHCP = false;
    interfaces =
      [ { name = "eth0";
          ipAddress = "150.217.34.130";
          subnetMask = "255.255.255.128";
        }
      ];
    defaultGateway = "150.217.34.129";
    extraHosts = ''
      150.217.33.145 neve
    '';
  };

  environment.systemPackages =
    with pkgs;
    [ emacs screen mosh
      #emacsPackages.magit
      #emacsPackages.ocamlMode
      mercurial darcs fossil mtr
      gitAndTools.gitFull
      gitAndTools.gitAnnex
      lynx links w3m
      ocaml coq
      firefoxWrapper
      chromeWrapper
    ];

  services.locate.enable = true;
  services.locate.period = "40 3 * * *";
  services.openssh.enable = true;
  services.openssh.allowSFTP = true;

  #services.openafsClient.enable = true;
  services.openafsClient.cellName = "math.unifi.it";

  services.postgresql.enable = true;

  time.timeZone = "Europe/Rome";

  #krb5.enable = true;
  krb5.defaultRealm = "MATH.UNIFI.IT";
  krb5.kdc = "kerberos.math.unifi.it";
  krb5.kerberosAdminServer = "kerberos.math.unifi.it";

  nix.maxJobs = 1;

  users.extraUsers =
    [ { name = "maggesi";
        description = "Marco Maggesi";
        home = "/home/maggesi";
        group = "users";
        extraGroups = [ "wheel" ];
        createHome = true;
        useDefaultShell = true;
      }
    ];
}
