# VirtualBox physical network specification for my "minicloud"
{
  webserver = 
    { config, pkgs, ... }:
    { deployment.targetEnv = "virtualbox";
      deployment.virtualbox.memorySize = 1024; # megabytes
    };
}