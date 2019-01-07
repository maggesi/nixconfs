{ stdenv, fetchFromGitHub, ocaml, num, camlp5 }:

let
  load_num =
    if num == null then "" else
      ''
        -I ${num}/lib/ocaml/${ocaml.version}/site-lib/num \
        -I ${num}/lib/ocaml/${ocaml.version}/site-lib/top-num \
        -I ${num}/lib/ocaml/${ocaml.version}/site-lib/stublibs \
      '';
 
  start_script =
    ''
      #!/bin/sh
      cd $out/lib/hol_light
      exec ${ocaml}/bin/ocaml \
        -I \`${camlp5}/bin/camlp5 -where\` \
        ${load_num} \
        -init make.ml
    '';
in

stdenv.mkDerivation {
  name     = "hol_light-2019-01-06";

  src = fetchFromGitHub {
    owner  = "jrh13";
    repo   = "hol-light";
    rev    = "a84e0f331053c0860ce80c5a541ff32c857e46c6";
    sha256 = "0r9x2yyhk8bcv21a6plinrnzyryqwc8wwkbck9kqkyb7f180f9p9";
  };

  buildInputs = [ ocaml camlp5 ];
  propagatedBuildInputs = [ num ];

  installPhase = ''
    mkdir -p "$out/lib/hol_light" "$out/bin"
    cp -a  . "$out/lib/hol_light"
    ls "$out/bin"
    echo "${start_script}" > $out/bin/hol_light
    chmod a+x "$out/bin/hol_light"
  '';

  meta = with stdenv.lib; {
    description = "Interactive theorem prover based on Higher-Order Logic";
    homepage    = http://www.cl.cam.ac.uk/~jrh13/hol-light/;
    license     = licenses.bsd2;
    platforms   = platforms.unix;
    maintainers = with maintainers; [ thoughtpolice z77z vbgl ];
  };
}
