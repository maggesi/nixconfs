{ config, pkgs, modulesPath, ... }:

let
  #hydrapkg = /nix/store/v70gk4mjqkyp2l4k73pxrbixinvzzsxr-hydra-0.1pre1051-4ad8912;
  hydrapkg = /nix/store/2a49h1zc3cydy97dyrv3ycfia087wwcy-hydra-0.1pre1058-fdf441a;

  nixosVHostConfig = {
    hostName = "elio.math.unifi.it";
    adminAddr = "maggesi@math.unifi.it";
    documentRoot = "/var/www";
    enableUserDir = true;
    logFormat = ''"%h %l %u %t \"%r\" %>s %b %D"'';

/*
    servedDirs = [
      { urlPath = "/tarballs";
        dir = "/data/webserver/tarballs";
      }
    ];

    servedFiles = [
      { urlPath = "/releases/css/releases.css";
        file = releasesCSS;
      }
    ];
*/

      extraConfig = ''
        TimeOut 900

        <Proxy *>
          Order deny,allow
          Allow from all
        </Proxy>

        ProxyRequests     Off
        ProxyPreserveHost On
        ProxyPass         /  http://localhost:3000/ retry=5 disablereuse=on
        ProxyPassReverse  /  http://localhost:3000/

        <Location />
          SetOutputFilter DEFLATE
          BrowserMatch ^Mozilla/4\.0[678] no-gzip\
          BrowserMatch \bMSI[E] !no-gzip !gzip-only-text/html
          SetEnvIfNoCase Request_URI \.(?:gif|jpe?g|png)$ no-gzip dont-vary
          SetEnvIfNoCase Request_URI /api/ no-gzip dont-vary
          SetEnvIfNoCase Request_URI /download/ no-gzip dont-vary
        </Location>
      '';
    };

in
{
  require = [
    #"${modulesPath}/virtualisation/xen-domU.nix"
    ./modules/hydra.nix
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
      mercurial darcs gitFull fossil mtr
      lynx links w3m
      ocaml coq
      pkgs.firefoxWrapper
      pkgs.chromeWrapper
    ];

  services.hydra = {
    enable = true;
    hydra = hydrapkg;
    hydraURL = "http://elio.math.unifi.it/";
    notificationSender = "maggesi@math.unifi.it";
    user = "hydra";
    baseDir = "/home/hydra";
    dbi = "dbi:Pg:dbname=hydra;host=localhost;user=hydra;";
    minimumDiskFree = 3;
    minimumDiskFreeEvaluator = 1;
    #tracker = "<div>Dipartimento di Matematica Ulisse Dini</div>";
    autoStart = true;
  };

  services.locate.enable = true;
  services.locate.period = "40 3 * * *";
  services.openssh.enable = true;
  services.openssh.allowSFTP = true;

  #services.openafsClient.enable = true;
  services.openafsClient.cellName = "math.unifi.it";

  services.postgresql.enable = true;

  services.httpd = {
    enable = true;
    logPerVirtualHost = true;
    adminAddr = "maggesi@math.unifi.it";
    hostName = "localhost";

    extraModules = [
      #### Questi non servono, sono caricaty per default
      # "rewrite" "proxy"
    ];

    extraConfig = ''
       AddType application/nix-package .nixpkg
    '';

    virtualHosts = [
      nixosVHostConfig

      (nixosVHostConfig // {
        enableSSL = true;
        sslServerCert = "/root/ssl-secrets/elio.crt";
        sslServerKey = "/root/ssl-secrets/elio.key";
	extraConfig = nixosVHostConfig.extraConfig + ''
          # Required by Catalyst.
          RequestHeader set X-Forwarded-Port 443
        '';
      })

     ];
  };

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
