# ~/.nixpkgs/config.nix
{
  packageOverrides = pkgs: rec {
    emacsEnv = pkgs.buildEnv
      { name = "emacs-env";
        paths = with pkgs.emacs23Packages;
          [ emacs
	    hol_light_mode
          ];
      };

/*
    miscEnv = pkgs.buildEnv
      { name = "misc-env";
        paths = with pkgs; [
	  coreutils diffutils findutils file which
        ];
      };
*/
  };
}