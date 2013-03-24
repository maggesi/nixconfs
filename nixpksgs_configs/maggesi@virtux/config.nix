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
        paths = with pkgs.emacs23Packages;
          [ emacs
	    #haskellMode
          ];
      };

    miscEnv = pkgs.buildEnv
      { name = "misc-env";
        paths = with pkgs; [
	  coreutils diffutils findutils file which
        ];
      };
  };
}