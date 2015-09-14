# nixpkgs configuration for maggesi@neve
# ~/.nixpkgs/config.nix
{
  packageOverrides = pkgs: rec {
    haskellEnv = pkgs.buildEnv
      { name = "haskell-env";
        paths = with pkgs.haskellPackages;
          [ ghc QuickCheck cmdlib ];
      };

    emacsEnv = pkgs.buildEnv
      { name = "emacs-env";
        paths = with pkgs.emacs24Packages;
          [ emacs
            #proofgeneral
            #haskellMode
            #hol_light_mode
          ];
      };

    miscEnv = pkgs.buildEnv
      { name = "misc-env";
        paths = with pkgs; [
          coreutils diffutils findutils file which
        ];
      };

    hol_light = with pkgs; import ../../../pkgs/hol_light {
      inherit stdenv fetchsvn writeScript;
      inherit (ocamlPackages) ocaml;
      camlp5 = ocamlPackages.camlp5_strict;
    };

    coq_hott = with pkgs; import ../../../pkgs/coq {
      inherit stdenv fetchgit pkgconfig ncurses;
      inherit (ocamlPackages) ocaml findlib lablgtk;
      camlp5 = ocamlPackages.camlp5_transitional;
    };

    hott = with pkgs; import ../../../pkgs/hott {
      inherit stdenv fetchgit;
      coq = coq_hott;
    };

    holl_mode = with pkgs; import ../../../pkgs/holl-mode {
      inherit stdenv fetchurl emacs;
    };
  };
}
