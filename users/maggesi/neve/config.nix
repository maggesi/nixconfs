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
	    proofgeneral
	    haskellMode
	    #hol_light_mode
          ];
      };

    miscEnv = pkgs.buildEnv
      { name = "misc-env";
        paths = with pkgs; [
	  coreutils diffutils findutils file which
 	];
      };

    holl_mode = with pkgs; import ../../../pkgs/holl-mode {
      inherit stdenv fetchurl emacs;
    };
  };
}
