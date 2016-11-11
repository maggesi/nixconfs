{ config, pkgs, modulesPath, ... }:

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

  require = [
    "${modulesPath}/virtualisation/xen-domU.nix"
    #../modules/xen-domU.nix
  ];

  # Needed for compatibility with the present version of BLCR
  boot.kernelPackages = custom_kernel.linuxPackages_3_14;

  fileSystems = [ { mountPoint = "/"; label = "nixos"; } ];
  swapDevices = [ { device = "/dev/xvda1"; } ];

  networking = {
    hostName = "elio";
    domain = "math.unifi.it";
    nameservers = [ "150.217.34.129" "150.217.34.211" ];
    defaultMailServer.directDelivery = true;
    defaultMailServer.hostName = "mail.math.unifi.it";

    firewall.enable = true;
    firewall.allowedTCPPorts = [ 80 443 5000 ];

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

  services.cron.enable = true;
  services.cron.mailto = "marco.maggesi@gmail.com";
  services.cron.systemCronJobs =
    [ "17    0 * * * root obnam forget --config /root/.obnam.conf"
      "27 1-23/6 * * * root obnam backup --config /root/.obnam.conf"
    ];

  environment.systemPackages = with pkgs; [ obnam emacs ];

  services.locate.enable = true;
  #services.locate.interval = "02:14"; #default
  services.openssh.enable = true;
  services.openssh.allowSFTP = true;

  services.ntp.enable = true;
  services.ntp.servers = ["ntp.unifi.it"];

  #services.httpd.enable = true;
  #services.httpd.adminAddr = "maggesi@math.unifi.it";
  #services.httpd.documentRoot = "/home/maggesi/public_html";

  services.lighttpd.enable = true;
  services.lighttpd.port = 443;
  services.lighttpd.enableModules = [ "mod_auth" ];
  services.lighttpd.extraConfig = ''
      ssl.engine = "enable"
      ssl.pemfile = "/srv/certs/lighttpd.pem"
      auth.backend = "htdigest"
      auth.backend.htdigest.userfile = "/srv/htdigest"
      auth.require = (
          "/cgit" => (
              "method"  => "digest",
              "realm"   => "cgit interface",
              "require" => "valid-user"
          )
      )
    '';
  services.lighttpd.cgit.enable = true;
  services.lighttpd.cgit.configText = ''
      cache-size=1000
      snapshots=tar.gz tar.bz2 tar.xz zip
      section-from-path=1
      scan-path=/home/maggesi/Repos/Git
    '';

  #services.openafsClient.enable = true;
  services.openafsClient.cellName = "math.unifi.it";

  services.postgresql.enable = false;

/*
  services.ihaskell.enable = true;
  services.ihaskell.extraPackages =
    haskellPackages: [ haskellPackages.wreq haskellPackages.lens ];
*/

  time.timeZone = "Europe/Rome";

  #krb5.enable = true;
  krb5.defaultRealm = "MATH.UNIFI.IT";
  krb5.kdc = "kerberos.math.unifi.it";
  krb5.kerberosAdminServer = "kerberos.math.unifi.it";

  nix.maxJobs = 1;

  nix.gc.automatic = true;
  nix.gc.dates = "13:15";
  nix.gc.options = "--delete-older-than 60d";

  nix.sshServe.enable = true;
  nix.sshServe.keys = [
    # root@crystal
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC/2HrwB09EfRWQ4le+cJTihrmsz/4roGxJA4+IrGF/KmWu8+02xdxebF94wHRO1cCLAUMaZV7RBQu5MNjsCB8rALqU+D0fd9ywqbhapp7fSp9UQcgcoMdonzA+HvbJ0w/b9wJF3FNfkS0Zp4PeLztGsToW47iGH3VpioTA0g3NFuJjKY0PYIFH0zBDMjCE7hMoALAf26n55W1yCK1gpfdNrThtcyIkmaqQZHyhP8PGwudJ4y2xNk1iyFcs6XsGrSmQzCuMIXQXjOA3atoCRFOPwogYy0itr8EICR/4ZgSXBWoMX2OFPktRz2GwclPhCgnEqRYyMPVA1mXVpLRTRTb7 root@crystal"
    # maggesi@crystal
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDj6Fy0LwW1Cj1BOf9Zk0k4KLi0dNCYMjucik8K3ts5UONwUby/eeOzegvM6n1bCPERy5O5Pj9RilnPCdA9MN5dxLK2zUkyQEp4/EpgeYk03H1QrI9PSqdj8zvtKDItM/pdcLhOelvldBzILsbZ4f60HRb08QmiX8o31HsU0e1+6cRjKXP4UfAg1qw1JuJdO/pY/TlsAOxdTFidKX4GYcqjVSExF91LKg1511jfM9ZG5RlenahQ3b5wXttykZjSveO5uzMi/daEj5ALGzzZ7ItOKBwIehlFyEz6sqoagS5weh0YF6F/VL6BW9LybHxsCX7ZqoUpJcdjyGWUDn7sven3 marco.maggesi@gmail.com"
    # root@neve
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDCBuU6zkmy87QOFtMnvwkKt0PPa0rTtg9WInVwyPc2Y6XtuxxQSaovw25jJz9FjLTqw5AnzD84M4CrEL1CaRh5u+5ntV5qrqslmDpDu8ourmpbNcL2dbGhuN4qdnAuYr391OsQ2z5OTZZUBzUrT1e4gg/U6kGfpb0L45UiWHhsB94ep8oNA+bwOx446zd3k/OBVU0f/U4DwS1Jym6J91U3hP2Y9WVaBmWmkk6BMVN548ZXKkI6mcCU0uMltYOwkOt4E+GHezdCYE0bfc/xoSsarBYYCbkPVzFiiXmaiRvavnN+msOB2vP8KzpQdC7jHkf9IwOXAwoK+yIEWaRjrQGt root@neve"
    # maggesi@neve
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDa8b0cgizsaZKszLd701sByujgArnhkVoGgTYGJEZRt0/8qjo96eiJykxqcneXByigeM0qosyhUXY3SSXyUK0plvjROKIzojYmuiNfR2yr/pTdP/BraFx8DU8YoEyrwj3bS3GX4nTY+cng+wa4o81ZxwENg5Q1QXsB0GVn51OTsHkbVQSNs+tR5WcxLo0fVUeb1K+HJkz1j7LDT33IZg6iuxlD1NGouojwBurTo2VdrSxPqA/S3OhP2vsjn5YYnUX0avHvnQ44lWMxipxAzJHa6iX6X/fQyDSy6PGHQnCCGqI7oXtp0HQajCs+cKWuFu3lfnOTEBAQnWljUSWyHhGL maggesi@neve"

    "cVhiJJkNqVhgrAzEOmENGakmaA74sPvNCDRs/xqMzto1Y7jnb7QAnjlbCOSHo/B7Qrq41qTrUZWgQJZ/LOwjNXNpR2usECyyA+zmRK6mWNvXk20JKc29CIptv4Bpq8J+CrF6PRYmgZvWlP41ndXj9tUabZUNYPoDrFqGYt7aOaMG67dQhV2j8NwT/4c4GRSz5ImeUkb/t maggesi@bantu"
    "1bZJHO3zY4nqJlU2YEI5GJX3xW8JjjTzE+BcpuObElS1Z0A9E+GpmVy3l+Y8cJIu8+CPPWLJKFxtNe3CMsaRUbgyPOrBuzmcGZbXOGApiANKNTBYaUqZgAzN7aX2k1H0GifwieO7q5dFfCrXffuKrSP5O2Uis7bS5xsGbetXUWticP05D/G5keFoXgSxEjJ3a1YopMFJv maggesi@virtux"
    "9ol2wqsO3MG44VUyOIozJDe/ak0kzfVS6gxoYDym7ZRWJ0XEqnCFlK+mBMHx2FL9Q/LNpuNmFZTPufScimgPvWmmq85odMuvwEUVEWTrv9neDaIspU7va3nRf79SYIbQoHFg97HsOGnISxCqiw87MzcetYU68khVcVUKUobyP2BT5zUywJmB1zVZL5ZFdBml5f52knw== marco.maggesi@gmail.com"
    "jHpPcJng9SkVNb2/WXHDtJRnt3IEnX+R/PQ0pIgBwIa3fYbUS6G0co71j3uvAdvd1qdvR4qDK4REP6u6tQLiDtxvmofurikM1X3efTlQNFMQRztJQNryy6bf5EEWWdwTvv836hQ1jUEB6LJ59Bn+cxbcP2nPL+Aq8RutBEKS4yHZvtYoCmBbY1i3XKm43QCuRhc/OgzVD maggesi@moon"
    "g+wa4o81ZxwENg5Q1QXsB0GVn51OTsHkbVQSNs+tR5WcxLo0fVUeb1K+HJkz1j7LDT33IZg6iuxlD1NGouojwBurTo2VdrSxPqA/S3OhP2vsjn5YYnUX0avHvnQ44lWMxipxAzJHa6iX6X/fQyDSy6PGHQnCCGqI7oXtp0HQajCs+cKWuFu3lfnOTEBAQnWljUSWyHhGL maggesi@neve"
    "8GhuBHs+qwDijbIFXvM7Bnu1V5RlfI3RQ9kPxc2gEbrSO9l5qfdrelA03wLYOEsfG0X/wv6CkBex3n4BvTE6O+wmkz5FgkMUHvosooUC85ZpPOzOG3DUCnrazPKZpjyS35Abl7u+UG/iyoqDqDEXyFPPI82/dydtm99gdO/hlnH56Uwzi/d300ADSJDD44v8N96wmD4Pd marco.maggesi@gmail.com"
    "ILsbZ4f60HRb08QmiX8o31HsU0e1+6cRjKXP4UfAg1qw1JuJdO/pY/TlsAOxdTFidKX4GYcqjVSExF91LKg1511jfM9ZG5RlenahQ3b5wXttykZjSveO5uzMi/daEj5ALGzzZ7ItOKBwIehlFyEz6sqoagS5weh0YF6F/VL6BW9LybHxsCX7ZqoUpJcdjyGWUDn7sven3 marco.maggesi@gmail.com" ];

  users.extraUsers.maggesi =
    { name = "maggesi";
      description = "Marco Maggesi";
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
