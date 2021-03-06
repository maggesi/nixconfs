# ~/.nixpkgs/config.nix
{
  packageOverrides = pkgs: rec {
    emacsEnv = pkgs.buildEnv
      { name = "emacs-env";
        paths = with pkgs.emacs24Packages;
          [ emacs
            #proofgeneral
            #hol_light_mode
          ];
      };

    miscEnv = pkgs.buildEnv
      { name = "misc-env";
        paths = with pkgs; [
          coreutils diffutils findutils file which
        ];
      };

    hol_light = with pkgs; import ../../pkgs/hol_light {
      inherit stdenv fetchFromGitHub;
      inherit (ocamlPackages) ocaml;
      num = null;
      camlp5 = ocamlPackages.camlp5_strict;
    };

    holl_mode = with pkgs; import ../../pkgs/holl-mode {
      inherit stdenv fetchurl emacs;
    };
  };
}
