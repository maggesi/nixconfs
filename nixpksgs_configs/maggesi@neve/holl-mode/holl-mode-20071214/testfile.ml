(* -*- holl -*- *)

(*
TODO
- run-holl automatico quando si esegue la prima istruzione.
- segnalare errore quando si manda un send phrase e non ci sono  i ";;".
- type_of veloce
- maiuscole??
*)

(* new_definition
     Exception: Failure "new_definition: term not closed".
       Potrebbe dipendere dal fatto che si sta cercando di fare una
       definizione ricorsiva.  Usare "define" oppure
       "new_recursive_definition <thm>"

   new_recursive_definition
     Exception: Failure "dest_const: not a constant".
     Exception: Failure "mk_abs: not a variable".
     Exception: Failure "hd".
       Potrebbe dipendere dal fatto che la definizione non e' data
       sotto forma di ricorsione primitiva.
     Exception: Failure "mk_abs: not a variable".
       Una costante con lo stesso nome della funzione che vogliamo
      definire e' gia' stata definita.  Exception: Failure "find".
      Puo' darsi che il principio di ricorsione fornito non e' quello
      giusto.

   define
     Exception: Failure "end_itlist".
     Exception: Failure "new_specification: Assumptions not allowed in
     theorem".
       Potrebbe dipendere dal fatto che HOL non riesce a dimostrare
       che la ricorsione e' ben fondata.
     Exception: Failure "close_definition_clauses: defining multiple
     functions".
       Una funzione con lo stesso nome e' stata gia' definita.
*)

1 + 1;; (* test *)
3 + 3;;

needs "Permutation/nummax.ml";;

let PRE_MAX = prove
  (`!n m. PRE (MAX n m) = MAX (PRE n) (PRE m)`,
   REWRITE_TAC [MAX] THEN ARITH_TAC);;

let MAX_EQ_0 = prove
  (`!m n. MAX m n = 0 <=> m = 0 /\ n = 0`,
   REWRITE_TAC [MAX] THEN ARITH_TAC);;

let MAXL_EQ_0 = prove
  (`!l. MAXL l = 0 <=> ALL (\x. x = 0) l`,
   LIST_INDUCT_TAC THEN ASM_REWRITE_TAC [MAXL; ALL; MAX_EQ_0] THEN
   EQ_TAC THEN STRIP_TAC THEN ASM_REWRITE_TAC []);;

let HDS_MAP_FILTER = new_definition
  `HDS = MAP HD o FILTER ((~) o NULL)`;;

let HDS = prove
  (`HDS [] = [] /\
   (!l. HDS (CONS [] l) = HDS l) /\
   (!h t l. HDS (CONS (CONS h t) l) = CONS h (HDS l))`,
   REWRITE_TAC [HDS_MAP_FILTER; FILTER; MAP; NULL; HD; o_THM]);;

let TLS_MAP_FILTER = new_definition
  `TLS = MAP TL o FILTER ((~) o NULL)`;;

let TLS = prove
  (`TLS [] = [] /\
   (!l. TLS (CONS [] l) = TLS l) /\
   (!h t l. TLS (CONS (CONS h t) l) = CONS t (TLS l))`,
   REWRITE_TAC [TLS_MAP_FILTER; FILTER; MAP; NULL; TL; o_THM]);;

let LIST_TRANSPOSE_TRUNCATED = new_recursive_definition num_RECURSION
  `(!l. LIST_TRANSPOSE_TRUNCATED 0 l = []) /\
   (!n l. LIST_TRANSPOSE_TRUNCATED (SUC n) l =
            if ALL NULL l then [] else
	    CONS (HDS l) (LIST_TRANSPOSE_TRUNCATED n (TLS l)))`;;

let LIST_TRANSPOSE_TRUNCATED_NIL = prove
  (`!n. LIST_TRANSPOSE_TRUNCATED n [] = []`,
   INDUCT_TAC THEN ASM_REWRITE_TAC [ALL; LIST_TRANSPOSE_TRUNCATED; NULL; HDS]);;

let LIST_TRANSPOSE_DEF = new_definition
  `!l. LIST_TRANSPOSE l = LIST_TRANSPOSE_TRUNCATED (MAXL (MAP LENGTH l)) l`;;

let MAXL_MAP_LENGTH_TLS = prove
  (`!l:((A)list)list. MAXL (MAP LENGTH (TLS l)) = PRE (MAXL (MAP LENGTH l))`,
   LIST_INDUCT_TAC THEN REWRITE_TAC [MAP; LENGTH; MAXL; TLS; PRE_MAX; PRE] THEN
   X_LIST_CASES_TAC `h:(A)list` THEN
   ASM_REWRITE_TAC [MAP; LENGTH; TLS; MAXL; MAX_0; PRE]);;

let ALL_NULL_TLS = prove
  (`!l. ALL NULL l ==> ALL NULL (TLS l)`,
   LIST_INDUCT_TAC THEN REWRITE_TAC [ALL; TLS; NULL_EQ_NIL] THEN
   STRIP_TAC THEN ASM_SIMP_TAC [TLS]);;

let ALL_NULL_LIST_TRANSPOSE_TRUNCATED = prove
  (`!l n. ALL NULL l ==> LIST_TRANSPOSE_TRUNCATED n l = []`,
   LIST_INDUCT_TAC THEN REWRITE_TAC [ALL; LIST_TRANSPOSE_TRUNCATED_NIL] THEN
   REWRITE_TAC [NULL_EQ_NIL] THEN GEN_TAC THEN STRIP_TAC THEN
   STRIP_ASSUME_TAC (SPEC `n:num` num_CASES) THEN
   ASM_REWRITE_TAC [ALL; NULL; HDS; TLS; LIST_TRANSPOSE_TRUNCATED]);;

let MAXL_MAP_LENGTH = prove
  (`!l. MAXL (MAP LENGTH l) = 0 <=> ALL NULL l`,
   REWRITE_TAC [MAXL_EQ_0; ALL_MAP; o_DEF; GSYM NULL_LENGTH; ETA_AX]);;

let LIST_TRANSPOSE = prove
  (`!l:((A)list)list.
      LIST_TRANSPOSE l =
        if ALL NULL l then [] else CONS (HDS l) (LIST_TRANSPOSE (TLS l))`,
   SUBGOAL_THEN
     `!n l:((A)list)list.
        MAXL (MAP LENGTH l) = n ==>
        LIST_TRANSPOSE l =
 	  if ALL NULL l then [] else CONS (HDS l) (LIST_TRANSPOSE (TLS l))`
    (fun th -> MESON_TAC [th]) THEN
   REWRITE_TAC [LIST_TRANSPOSE_DEF] THEN INDUCT_TAC THEN GEN_TAC THENL
   [REWRITE_TAC [MAXL_MAP_LENGTH] THEN DISCH_TAC THEN
    ASM_SIMP_TAC [ALL_NULL_LIST_TRANSPOSE_TRUNCATED];
    DISCH_TAC THEN
    SUBGOAL_THEN `~ALL NULL (l:((A)list)list)` ASSUME_TAC THENL
    [ASM_REWRITE_TAC [GSYM MAXL_MAP_LENGTH; NOT_SUC];
     ASM_REWRITE_TAC [LIST_TRANSPOSE_TRUNCATED; MAXL_MAP_LENGTH_TLS; PRE]]]);;

let SORTED_DEF = new_recursive_definition list_RECURSION
  `(!le. SORTED le [] <=> T) /\
   (!le h t. SORTED le (CONS h t) <=> (NULL t \/ (le h (HD t) /\ SORTED le t)))`;;

let SORTED = prove
  (`(!le. SORTED le []) /\
   (!le x. SORTED le [x]) /\
   (!le x y t. SORTED le (CONS x (CONS y l)) <=> le x y /\ SORTED le (CONS y l))`,
  REWRITE_TAC [SORTED_DEF; NULL; HD]);;

let LIST_TRANSPOSE_IDEMP = prove;;
g `!l. SORTED (>=) (MAP LENGTH l) ==> LIST_TRANSPOSE (LIST_TRANSPOSE l) = l`;;
