{ nixpkgs ? <nixpkgs>
, nixos ? <nixos>
, configuration ? <configuration>
}:

let
  pkgs = import nixpkgs { };
  eval = import (nixos + "/lib/eval-config.nix") {
    inherit pkgs;
    modules = [ configuration ];
  };
in {
  system = eval.config.system.build.toplevel;
}