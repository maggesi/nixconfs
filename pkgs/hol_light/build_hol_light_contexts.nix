let
  sysver = builtins.getEnv "SYSVER";
  cr_checkpoint = <blcr/cr_checkpoint>;
  cr_run = <blcr/cr_run>;
  cr_restart = <blcr/cr_restart>;
  
  zcr_restart = import ../zcr_restart {
    inherit stdenv cr_restart;
  };

  pkgs = import <nixpkgs> {};
  inherit (pkgs) stdenv ocamlPackages;
  inherit (ocamlPackages) ocaml;
  camlp5 = ocamlPackages.camlp5_strict;

  blcr_selfdestruct_ml = pkgs.writeText "blcr_selfdestruct.ml" ''
(* ========================================================================= *)
(* Create a standalone HOL image. Assumes that we are running under Linux    *)
(* and have the program BLCR available to create checkpoints.                *)
(* ========================================================================= *)

let startup_banner () =
   let {Unix.tm_mday = d;Unix.tm_mon = m;Unix.tm_year = y;Unix.tm_wday = w} =
     Unix.localtime(Unix.time()) in
  let nice_date = string_of_int d ^ " " ^
    el m ["January"; "February"; "March"; "April"; "May"; "June";
          "July"; "August"; "September"; "October"; "November"; "December"] ^
    " " ^ string_of_int(1900+y) in
  "        HOL Light "^hol_version^
  ", built "^nice_date^" on OCaml "^Sys.ocaml_version;;

let blcr_selfdestruct filename bannerstring =
  let longer_banner = startup_banner()^" with BLCR" in
  let complete_banner =
    if bannerstring = "" then longer_banner
    else longer_banner^"\n        "^bannerstring in
  let cr_checkpoint = "${toString cr_checkpoint}" in
  let command = cr_checkpoint^" --term -f "^filename^" -p $PPID" in
  Gc.compact();
  ignore (search[`1`]);
  Unix.sleep 1;
  Format.print_string "Checkpointing... "; Format.print_newline();
  (try ignore(Unix.system command) with Unix.Unix_error _ -> ());
  Format.print_string complete_banner; Format.print_newline();
  Format.print_newline();;
'';

  mkContext = {
    variant,
    description ? "",
    load_script,
    initial_state ? "${toString cr_run} ocaml -I `camlp5 -where`"
  }: stdenv.mkDerivation {
    name = "hol_light_${variant}.context.gz";
    inherit load_script;
    buildInputs = [ ocaml camlp5 ];
    buildCommand = ''
      loadScript=$(mktemp --tmpdir "${variant}_load-XXXXXX.ml")
      tmpContext=$(mktemp --tmpdir "${variant}-XXXXXX.context")
      selfdestruct="blcr_selfdestruct \"$tmpContext\" \"${description}\";;"
      echo "$load_script" >> "$loadScript"
      echo "$selfdestruct" >> "$loadScript"
      cat "$loadScript" | ${initial_state} || true
      echo "Compressing $tmpContext.."
      gzip -9 "$tmpContext"
      echo mv "$tmpContext.gz" "$out"
      mv "$tmpContext.gz" "$out"
    '';
  };

  mkRestartScript = variant: context:
    pkgs.writeScript "hol_light_${variant}" ''
      #!/bin/sh
      if [ -z "$TMPDIR" ]; then TMPDIR="/tmp"; fi 
      ZCR_RESTART="${zcr_restart}/bin/zcr_restart"
      CONTEXT="${context}"
      HOL_RESTART=$(mktemp --tmpdir "hol_cwd_command.XXXX")
      printf 'let () = ' > $HOL_RESTART
      printf 'let restart_cwd = "%q" in ' "$(pwd)" >> $HOL_RESTART
      printf 'let restart_path = "%q" in ' "$PATH" >> $HOL_RESTART
      printf 'Filename.set_temp_dir_name "%q"; ' "$TMPDIR" >> $HOL_RESTART
      printf 'temp_path := "%q"; ' "$TMPDIR" >> $HOL_RESTART
      printf 'Unix.putenv "TMPDIR" "%q"; ' "$TMPDIR" >> $HOL_RESTART
      cat >> $HOL_RESTART <<EOF
      Format.print_string "Setup restart environment.";
      Format.print_newline();
      let parent_dir = Filename.dirname restart_cwd in
      load_path := parent_dir :: !load_path;
      Sys.chdir restart_cwd;
      Unix.putenv "PATH" restart_path;;
      EOF
      trap "" SIGINT
      cat $HOL_RESTART - | exec "$ZCR_RESTART" "$CONTEXT"
      rm -f $HOL_RESTART
    '';

  mkVariant = arg: mkRestartScript arg.variant (mkContext arg);

in rec {
  hol_light_core_conf = {
    variant = "core";
    description = "Preloaded with the core system";
    load_script = ''
      Sys.chdir "${pkgs.hol_light}/lib/hol_light";;
      #use "make.ml";;
      let sysver = "${sysver}";;
      loadt "${blcr_selfdestruct_ml}";;
      loads "update_database.ml";;
    '';
  };

  hol_light_test_conf = {
    variant = "test";
    description = "Just a cheap test of the checkpointing mechanism";
    initial_state =
      "\"${zcr_restart}/bin/zcr_restart\" \"${hol_light_core_context}\"";
    load_script = ''
      let foo = 1+1;;
    '';
  };

  hol_light_multivariate_conf = {
    variant = "multivariate";
    description = "Preloaded with multivariate analysis";
    initial_state =
      "\"${zcr_restart}/bin/zcr_restart\" \"${hol_light_core_context}\"";
    load_script = ''
      loads "Multivariate/make.ml";
      prioritize_num();;
    '';
  };

  hol_light_complex_conf = {
    variant = "complex";
    description = "Preloaded with multivariate-based complex analysis";
    initial_state =
      "\"${zcr_restart}/bin/zcr_restart\" \"${hol_light_multivariate_context}\"";
    load_script = ''
      loads "Library/binomial.ml";;
      loads "Library/iter.ml";;
      loads "Multivariate/complexes.ml";;
      loads "Multivariate/canal.ml";;
      loads "Multivariate/transcendentals.ml";;
      loads "Multivariate/realanalysis.ml";;
      loads "Multivariate/moretop.ml";;
      loads "Multivariate/cauchy.ml";;
      loads "Multivariate/complex_database.ml";;
      prioritize_num();;
    '';
  };

  hol_light_sosa_conf = {
    variant = "sosa";
    description = "Preloaded with analysis and SOS";
    initial_state =
      "\"${zcr_restart}/bin/zcr_restart\" \"${hol_light_core_context}\"";
    load_script = ''
      loads "Library/analysis.ml";;
      loads "Library/transc.ml";;
      loads "Examples/sos.ml";;
    '';
  };

  hol_light_card_conf = {
    variant = "card";
    description = "Preloaded with cardinal arithmetic";
    initial_state =
      "\"${zcr_restart}/bin/zcr_restart\" \"${hol_light_core_context}\"";
    load_script = ''
      loads "Library/card.ml";;
    '';
  };

  hol_light_gcs_conf = {
    variant = "gcs";
    description = "Geometria Computazionale Simbolica 2013-2014";
    initial_state =
      "\"${zcr_restart}/bin/zcr_restart\" \"${hol_light_complex_context}\"";
    load_script = ''
      loadt "${./gcs.hl}";;
      prioritize_num();;
      type_invention_error := true;;
    '';
  };

  hol_light_hypercomplex_conf = {
    variant = "hypercomplex";
    description = "Preloaded with complex analysis and quaternions";
    initial_state =
      "\"${zcr_restart}/bin/zcr_restart\" \"${hol_light_complex_context}\"";
    load_script = ''
      loads "Quaternions/make.ml";;
      prioritize_num();;
    '';
  };

  hol_light_core_context = mkContext hol_light_core_conf;
  hol_light_test_context = mkContext hol_light_test_conf;
  hol_light_multivariate_context = mkContext hol_light_multivariate_conf;  
  hol_light_complex_context = mkContext hol_light_complex_conf;  
  hol_light_sosa_context = mkContext hol_light_sosa_conf;  
  hol_light_card_context = mkContext hol_light_card_conf;  
  hol_light_gcs_context = mkContext hol_light_gcs_conf;
  hol_light_hypercomplex_context = mkContext hol_light_hypercomplex_conf;

  hol_light_core = mkVariant hol_light_core_conf;
  hol_light_test = mkVariant hol_light_test_conf;
  hol_light_multivariate = mkVariant hol_light_multivariate_conf;  
  hol_light_complex = mkVariant hol_light_complex_conf;  
  hol_light_sosa = mkVariant hol_light_sosa_conf;  
  hol_light_card = mkVariant hol_light_card_conf;  
  hol_light_gcs = mkVariant hol_light_gcs_conf;
  hol_light_hypercomplex = mkVariant hol_light_hypercomplex_conf;
}
