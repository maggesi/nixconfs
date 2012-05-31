# o0dom0 system.  Help is available in the configuration.nix(5) man page
# or the NixOS manual available on virtual console 8 (Alt+F8).

{ config, pkgs, ... }:

{
  require =
    [ ./hardware-configuration.nix    # Results of the hardware scan.
    ];

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
  services.gpm.enable = true;

  environment.systemPackages =
    with pkgs;
    [ diffutils file which gnumake
      emacs mc mosh
      # patch
      screen subversion
      links w3m lynx wget
    ];

  #virtualisation.xen.enable = true;
  #virtualisation.xen.domain0MemorySize = 512;
}
