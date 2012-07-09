# o0dom0 system.  Help is available in the configuration.nix(5) man page
# or the NixOS manual available on virtual console 8 (Alt+F8).

{ config, pkgs, ... }:

let
  #hydrapkg = /nix/store/2a49h1zc3cydy97dyrv3ycfia087wwcy-hydra-0.1pre1058-fdf441a;
  hydrapkg = /nix/store/i2fp402jvl9hs2l5r033bm9vscl5g0kj-hydra-0.1pre1074-1b3cf68;

  nixosVHostConfig = {
    hostName = "o0dom0.math.unifi.it";
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
    ../modules/hydra.nix
    ./hardware-configuration.nix    # Results of the hardware scan.
  ];

  environment.shellInit = ''
    export HYDRA_DATA=/home/hydra/data
    export HYDRA_DBI="dbi:Pg:dbname=hydra;host=localhost;user=hydra;";
  '';

  #boot.kernelPackages = pkgs.linuxPackages_3_2_xen;
    
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.device = "/dev/sda";

  networking = {
    hostName = "o0dom0";
    domain = "math.unifi.it";
    nameservers = [ "150.217.34.129" "150.217.34.211" ];
    defaultMailServer.directDelivery = true;
    defaultMailServer.hostName = "mail.math.unifi.it";
      
    useDHCP = false;
    interfaces =
      [ { name = "eth0";
          ipAddress = "150.217.34.247";
          subnetMask = "255.255.255.128";
        }
      ];
    defaultGateway = "150.217.34.129";
    extraHosts = ''
      150.217.33.145 neve
    '';
  };

  fileSystems =
    [ { mountPoint = "/";
#        device = "/dev/disk/by-label/nixos";
        device = "/dev/disk/by-label/store";
      }

       { mountPoint = "/home"; # where you want to mount the device
         device = "/dev/disk/by-label/home";
         #device = "/dev/sdb";  # the device
         #fsType = "ext3";      # the type of the partition
         #options = "data=journal";
       }
    ];

  swapDevices =
    [ { device = "/dev/disk/by-label/swap"; }
    ];

  services.nixosManual.showManual = true;
  services.openssh.enable = true;
  services.openssh.allowSFTP = true;
  services.gpm.enable = true;

  environment.systemPackages =
    with pkgs;
    [ emacs screen mosh tmux
      #emacsPackages.magit
      #emacsPackages.ocamlMode
      mercurial darcs fossil mtr
      gitAndTools.gitFull
      gitAndTools.gitAnnex
      lynx links w3m
      # ocaml
      # coq
      pkgs.firefoxWrapper
      pkgs.chromeWrapper

      diffutils file which gnumake
      mc 
      # patch
      subversion
      links w3m wget
    ];

  #virtualisation.xen.enable = true;
  #virtualisation.xen.domain0MemorySize = 512;

  services.hydra = {
    enable = true;
    hydra = hydrapkg;
    hydraURL = "http://o0dom0.math.unifi.it/";
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
        sslServerCert = "/root/ssl-secrets/server.crt";
        sslServerKey = "/root/ssl-secrets/server.key";
	extraConfig = nixosVHostConfig.extraConfig + ''
          # Required by Catalyst.
          RequestHeader set X-Forwarded-Port 443
        '';
      })

     ];
  };

  time.timeZone = "Europe/Rome";

  users.extraUsers = [
    { name = "maggesi";
      description = "Marco Maggesi";
      home = "/home/maggesi";
      group = "users";
      extraGroups = [ "wheel" ];
      createHome = true;
      useDefaultShell = true;
    }
  ];
}
