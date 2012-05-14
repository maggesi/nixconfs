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
    systemPackages = [
      pkgs.emacs
      pkgs.screen
      pkgs.mosh
    ];
  };

services.openssh.enable = true;

}
