{ config, pkgs, modulesPath, ... }:

{
  require = [ "${modulesPath}/virtualisation/xen-domU.nix" ];

  fileSystems = 
    [ { mountPoint = "/";
        label = "nixos";
      }
    ];

  networking = {
    hostName = "dolly";
    nameservers = [ "150.217.34.1"  "150.217.34.211" ];
    defaultMailServer.directDelivery = true;
    defaultMailServer.hostName = "mail.math.unifi.it";

    useDHCP = false;
    interfaces = [ {
      name = "eth0";
      ipAddress = "150.217.34.130";
      subnetMask = "255.255.255.128";
    } ];
    defaultGateway = "150.217.34.129";

  };

  environment = {
    systemPackages = with pkgs; [
      emacs screen mosh
      mercurial darcs git fossil
      ocaml
      coq
    ];
  };

  services.locate.enable = true;
  services.locate.period = "40 3 * * *";
  services.openssh.enable = true;




  services.openafsClient = {
      enable = false;
      cellName = "math.unifi.it";
    };
  services.postgresql.enable = true;

  services.httpd = {
      enable = true;
      hostName = "localhost";
      adminAddr = "maggesi@math.unifi.it";
      documentRoot = "/var/www";
      enableUserDir = true;
      /*
      servedDirs = [
        { dir = "/home/maggesi/Devel"; urlPath = "/devo"; }
        { dir = "/nix/store"; urlPath = "/store"; }
      ];
      extraModules = [
        { name = "php5"; path = "${pkgs.php}/modules/libphp5.so"; }
      ];
      extraConfig = ''
        ScriptAlias /cgi-bin/ /var/www/cgi-bin/
      '';
      */
    };

  time.timeZone = "Europe/Rome";

  krb5.enable = false;
  krb5.defaultRealm = "MATH.UNIFI.IT";
  krb5.kdc = "kerberos.math.unifi.it";
  krb5.kerberosAdminServer = "kerberos.math.unifi.it";


}
