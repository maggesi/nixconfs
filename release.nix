{ nixpkgsSrc ? <nixpkgs>
, nixosSrc ? <nixos>
}:

let
  system = "i686-linux";
  pkgs = import nixpkgsSrc { inherit system; };
  eval = conf: import (nixosSrc + "/lib/eval-config.nix")
    { inherit pkgs system;
      modules = [ conf ];
    };
in
{ 
  elio = (eval ./elio.nix).config.system.build.toplevel;
  neve = (eval ./neve/configuration.nix).config.system.build.toplevel;
  virtux = (eval ./virtux.nix).config.system.build.toplevel;
}
