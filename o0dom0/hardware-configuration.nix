# This is a generated file.  Do not modify!
# Make changes to /etc/nixos/configuration.nix instead.
{ config, pkgs, modulesPath, ... }:

{
  require = [
    #<nixos/modules/installer/scan/not-detected.nix>
    (modulesPath + /installer/scan/not-detected.nix)
  ];

  boot.initrd.kernelModules = [ "uhci_hcd" "ehci_hcd" "ata_piix" "megaraid_sas" "usbhid" ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  nix.maxJobs = 12;
}
