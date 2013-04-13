# This is a generated file.  Do not modify!
# Make changes to /etc/nixos/configuration.nix instead.
{ config, pkgs, modulesPath, ... }:

{
  require = [
    #<nixos/modules/installer/scan/not-detected.nix>
    (modulesPath + /installer/scan/not-detected.nix)
  ];

  boot.initrd.kernelModules = [ "ata_piix" "ohci_hcd" "ahci" ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];

  nix.maxJobs = 1;

  services.virtualbox.enable = true;
}
