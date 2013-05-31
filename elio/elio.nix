{ config, pkgs, modulesPath, ... }:

{
  require = [
    # "${modulesPath}/virtualisation/xen-domU.nix"
    ./xen-domU.nix
  ];

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

  services.locate.enable = true;
  services.locate.period = "40 3 * * *";
  services.openssh.enable = true;
  services.openssh.allowSFTP = true;

  #services.openafsClient.enable = true;
  services.openafsClient.cellName = "math.unifi.it";

  services.postgresql.enable = false;

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
