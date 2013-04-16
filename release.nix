{ nixpkgsSrc ? <nixpkgs>
, nixosSrc ? <nixos>
}:

let
  system = builtins.currentSystem;
  pkgs = import nixpkgsSrc { inherit system; };
  eval = conf: import (nixosSrc + "/lib/eval-config.nix")
    { inherit pkgs system;
      modules = [ conf ];
    };
in
{ 
  dolly = (eval ./dolly.nix).config.system.build.toplevel;
  elio = (eval ./elio.nix).config.system.build.toplevel;
  neve = (eval ./neve/configuration.nix).config.system.build.toplevel;
  o0dom0 = (eval ./o0dom0/o0dom0-hydra.nix).config.system.build.toplevel;
  o0dom0_xen = (eval ./o0dom0/o0dom0-xen.nix).config.system.build.toplevel;
  virtux = (eval ./virtux/configuration.nix).config.system.build.toplevel;
  holinux = (eval ./holinux/holinux.nix).config.system.build.toplevel;
}
