# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, pkgs, ... }:

{
  imports =
    [ <nixpkgs/nixos/modules/installer/scan/not-detected.nix>
    ];

  boot.initrd.availableKernelModules = [ "ata_piix" "ohci_hcd" ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "/dev/sda1";
      fsType = "ext4";
    };

  fileSystems."/var/setuid-wrappers" =
    { device = "none";
      fsType = "tmpfs";
    };

  swapDevices =
    [ { device = "/dev/sdb1"; }
    ];

  nix.maxJobs = 1;
  services.virtualboxGuest.enable = true;
}
