let
  sysver = builtins.getEnv "SYSVER";
  cr_checkpoint = <blcr/cr_checkpoint>;
  cr_run = <blcr/cr_run>;
  cr_restart = <blcr/cr_restart>;
  pkgs = import <nixpkgs> {};
  inherit (pkgs) stdenv ocamlPackages;
  inherit (ocamlPackages) ocaml findlib;
  camlp5 = ocamlPackages.camlp5_strict;

  blcr_selfdestruct_ml = pkgs.writeText "blcr_selfdestruct.ml" ''
(* ========================================================================= *)
(* Create a standalone HOL image. Assumes that we are running under Linux    *)
(* and have the program BLCR available to create checkpoints.                *)
(* ========================================================================= *)

let blcr_selfdestruct filename bannerstring =
  let longer_banner = startup_banner^" with BLCR" in
  let complete_banner =
    if bannerstring = "" then longer_banner
    else longer_banner^"\n        "^bannerstring in
  let cr_checkpoint = "${toString cr_checkpoint}" in
  let command = cr_checkpoint^" --term -f "^filename^" $PPID" in
  Gc.compact(); Unix.sleep 1;
  Format.print_string "Checkpointing... "; Format.print_newline();
  (try ignore(Unix.system command) with Unix.Unix_error _ -> ());
  Format.print_string complete_banner; Format.print_newline();
  Format.print_newline();;
'';

  mkContext = {
    variant,
    description ? "",
    load_script,
    initial_state ? "${toString cr_run} ocaml -I `ocamlfind query camlp5`"
  }: stdenv.mkDerivation {
    name = "hol_light_${variant}";
    inherit load_script;
    buildInputs = [ ocaml camlp5 findlib ];
    buildCommand = ''
      ensureDir "$out/lib/hol_light/contexts"
      loadScript="$out/lib/hol_light/contexts/${variant}_load.ml"
      contextFile="$out/lib/hol_light/contexts/${variant}.context"
      echo "$load_script" >> "$loadScript"
      echo "blcr_selfdestruct \"$NIX_BUILD_TOP/hol.context\" \"${description}\";;" >> "$loadScript"
      cat "$loadScript" | ${initial_state} || true
      mv "$NIX_BUILD_TOP/hol.context" "$contextFile"
    '';
  };

  mkRestartScript = variant: context:
    pkgs.writeScript "hol_light_${variant}" ''
      #!/bin/sh
      exec ${cr_restart} --no-restore-pid \
       ${context}/lib/hol_light/contexts/${variant}.context
    '';

  mkVariant = arg: mkRestartScript arg.variant (mkContext arg);

in rec {
  hol_light_core = mkVariant {
    variant = "core";
    description = "Preloaded with the core system";
    load_script = ''
      Sys.chdir "${pkgs.hol_light}/lib/hol_light";;
      #use "make.ml";;
      let sysver = "${sysver}";;
      loadt "${blcr_selfdestruct_ml}";;
      loadt "update_database.ml";;
    '';
  };

  hol_light_multivariate = mkVariant {
    variant = "multivariate";
    description = "Preloaded with multivariate analysis";
    initial_state = hol_light_core;
    load_script = ''
      loadt "Multivariate/make.ml";
    '';
  };

  hol_light_complex = mkVariant {
    variant = "complex";
    description = "Preloaded with multivariate-based complex analysis";
    initial_state = hol_light_multivariate;
    load_script = ''
      loadt "Library/binomial.ml";;
      loadt "Library/iter.ml";;
      loadt "Multivariate/complexes.ml";;
      loadt "Multivariate/canal.ml";;
      loadt "Multivariate/transcendentals.ml";;
      loadt "Multivariate/realanalysis.ml";;
      loadt "Multivariate/moretop.ml";;
      loadt "Multivariate/cauchy.ml";;
      loadt "Multivariate/complex_database.ml";;
    '';
  };

  hol_light_sosa = mkVariant {
    variant = "sosa";
    description = "Preloaded with analysis and SOS";
    initial_state = hol_light_core;
    load_script = ''
      loadt "Library/analysis.ml";;
      loadt "Library/transc.ml";;
      loadt "Examples/sos.ml";;
    '';
  };

  hol_light_card = mkVariant {
    variant = "card";
    description = "Preloaded with cardinal arithmetic";
    initial_state = hol_light_core;
    load_script = ''
      loadt "Library/card.ml";;
    '';
  };

  hol_light_test = mkVariant {
    variant = "test";
    description = "Just a cheap test of the checkpointing mechanism";
    initial_state = hol_light_core;
    load_script = ''
      let foo = 1+1;;
    '';
  };

  hol_light_gcs = mkVariant {
    variant = "gcs";
    description = "Geometria Computazionale Simbolica 2013-2014";
    initial_state = hol_light_complex;
    load_script = ''
      loadt "${./gcs.hl}";;
      prioritize_num();;
      type_invention_error := true;;
      ignore (search[`1`]);;
    '';
  };

  hol_light_hypercomplex = mkVariant {
    variant = "hypercomplex";
    description = "Preloaded with complex analysis and quaternions";
    initial_state = hol_light_complex;
    load_script = ''
      load_path := "${../../../HOL}" :: !load_path;;
      Format.print_string (Sys.getcwd()); Format.print_newline();
      loadt "Quaternions/make.hl";;
      ignore (search[`1`]);;
    '';
  };

}
