{ config, pkgs, modulesPath, ... }:

{
  require = [
    "${modulesPath}/virtualisation/xen-domU.nix"
    #../modules/xen-domU.nix
  ];

  # Needed for compatibility with the present version of BLCR
  boot.kernelPackages = pkgs.linuxPackages_3_14;

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

  services.cron.enable = true;
  services.cron.mailto = "marco.maggesi@gmail.com";
  services.cron.systemCronJobs =
    [ "17 5 * * * root obnam forget --config /root/.obnam.conf"
      "27 1-23/3 * * * root obnam backup --config /root/.obnam.conf"
    ];

  services.locate.enable = true;
  services.locate.period = "40 3 * * *";
  services.openssh.enable = true;
  services.openssh.allowSFTP = true;

  services.ntp.enable = true;
  services.ntp.servers = ["ntp.unifi.it"];

  services.httpd.enable = true;
  services.httpd.adminAddr = "maggesi@math.unifi.it";
  services.httpd.documentRoot = "/home/maggesi/public_html";

  #services.openafsClient.enable = true;
  services.openafsClient.cellName = "math.unifi.it";

  services.postgresql.enable = false;

  # Gitolite configuration
  services.gitolite.user =  "git";
  services.gitolite.dataDir = "/var/lib/gitolite";
  services.gitolite.enable = true;
  services.gitolite.adminPubkey =
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCuaQkTZTJyRp24IsmdXUKCBr5XKSIyw3OYL1o2SMU1vKYrSIjpHSJ/7F1FwJa89HZVukuj1i0JQfUp08GITDG21YnsSJIkqa7+QdYPo9fwtcZX505shH0PYZg8PYbuxOb8VFHhi7/SJZd8GhuBHs+qwDijbIFXvM7Bnu1V5RlfI3RQ9kPxc2gEbrSO9l5qfdrelA03wLYOEsfG0X/wv6CkBex3n4BvTE6O+wmkz5FgkMUHvosooUC85ZpPOzOG3DUCnrazPKZpjyS35Abl7u+UG/iyoqDqDEXyFPPI82/dydtm99gdO/hlnH56Uwzi/d300ADSJDD44v8N96wmD4Pd marco.maggesi@gmail.com";

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
    "b+J7JbwWK3crIUe6mktC7uFZa+NOX/fVynpDP/WDaG7SnS9T6my+yg4tSB/Y2k6irRxo9oakgM224hLYTaL46CweHHLxEI0AAXhzi/pPKnRNhjX7lt1TE6a+xnuWCOeKe/wEnCpSg33VkcWWFi5h7tYOeHyzYYlRMS3VWVbrWGmb5WXRfYRwTEoxQ2FDBrYWx9+Gt+vBh maggesi@neve"
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
