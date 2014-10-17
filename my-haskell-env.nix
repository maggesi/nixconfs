let
    pkgs = import <nixpkgs> {};
    hsEnv = pkgs.haskellPackages.ghcWithPackages (hsPkgs : ([
      hsPkgs.HaRe
      hsPkgs.hlint
      hsPkgs.hdevtools
      hsPkgs.monadControl
      hsPkgs.hasktags]
      ));
      # ++
      # Include the deps of our project to make them available for tools:
      #(hsPkgs.callPackage ./my-haskell-project.nix {}).propagatedNativeBuildInputs));
  in
    pkgs.myEnvFun {
      name = "my-haskell-project";
      buildInputs = with pkgs; [
        # development tools as fits your needs
        binutils
        coreutils
        hsEnv
        ];
      extraCmds = ''
        $(grep export ${hsEnv.outPath}/bin/ghc)
      '';
      }
