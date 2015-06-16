{ config, pkgs, modulesPath, ... }:

{
  require = [
    "${modulesPath}/virtualisation/xen-domU.nix"
    #../modules/xen-domU.nix
  ];

  # Needed for compatibility with the present version of BLCR
  # boot.kernelPackages = pkgs.linuxPackages_3_4;

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
	  prefixLength = 25;
          #subnetMask = "255.255.255.128";
        }
      ];
    defaultGateway = "150.217.34.129";
    extraHosts = "150.217.33.63 neve";
  };

  environment.blcr.enable = true;

  services.locate.enable = true;
  services.locate.period = "40 3 * * *";
  services.openssh.enable = true;
  services.openssh.allowSFTP = true;

  services.httpd.enable = true;
  services.httpd.adminAddr = "maggesi@math.unifi.it";
  services.httpd.documentRoot = "/home/maggesi/public_html";

  #services.openafsClient.enable = true;
  services.openafsClient.cellName = "math.unifi.it";

  services.postgresql.enable = false;

  time.timeZone = "Europe/Rome";

  #krb5.enable = true;
  krb5.defaultRealm = "MATH.UNIFI.IT";
  krb5.kdc = "kerberos.math.unifi.it";
  krb5.kerberosAdminServer = "kerberos.math.unifi.it";

  nix.maxJobs = 1;
  nix.gc.automatic = true;
  nix.gc.dates = "13:15";
  nix.gc.options = "--delete-older-than 60d";

  users.extraUsers.maggesi =
    { name = "maggesi";
      description = "Marco Maggesi";
      home = "/home/maggesi";
      group = "users";
      extraGroups = [ "wheel" ];
      createHome = true;
      useDefaultShell = true;
    };

  users.extraUsers.barlocco =
    { name = "barlocco";
      description = "Simone Barlocco";
      home = "/home/maggesi";
      group = "users";
      extraGroups = [ "wheel" ];
      createHome = true;
      useDefaultShell = true;
    };

  users.extraUsers.annex =
    { createHome = true;
      home = "/home/annex";
      description = "Sharing account for git annex assistant";
      # extraGroups = [ "wheel" ];
      useDefaultShell = true;
      openssh.authorizedKeys.keys = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCuaQkTZTJyRp24IsmdXUKCBr5XKSIyw3OYL1o2SMU1vKYrSIjpHSJ/7F1FwJa89HZVukuj1i0JQfUp08GITDG21YnsSJIkqa7+QdYPo9fwtcZX505shH0PYZg8PYbuxOb8VFHhi7/SJZd8GhuBHs+qwDijbIFXvM7Bnu1V5RlfI3RQ9kPxc2gEbrSO9l5qfdrelA03wLYOEsfG0X/wv6CkBex3n4BvTE6O+wmkz5FgkMUHvosooUC85ZpPOzOG3DUCnrazPKZpjyS35Abl7u+UG/iyoqDqDEXyFPPI82/dydtm99gdO/hlnH56Uwzi/d300ADSJDD44v8N96wmD4Pd marco.maggesi@gmail.com" ];
    };
}
