{ stdenv, fetchgit, writeScript, ocaml, camlp5 }:

let
  start_script = ''
    #!/bin/sh
    cd "$out/lib/hol_light"
    exec ${ocaml}/bin/ocaml -I \`${camlp5}/bin/camlp5 -where\` -init make.ml
  '';
in

stdenv.mkDerivation {
  name = "hol_light-2016-10-30";

  src = fetchgit {
    url = https://github.com/jrh13/hol-light/;
    rev = "e9ba5fbc3d4c50d00fff0709cf72107a215159cf";
    sha256 = "1252abzda7kvqia98lm2r9r6bw2dq4b4jph75xzp0ng4msblr1kn";
  };

  buildInputs = [ ocaml camlp5 ];

  installPhase = ''
    mkdir -p "$out/lib/hol_light" "$out/bin"
    cp -a  . $out/lib/hol_light
    echo "${start_script}" > "$out/bin/hol_light"
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
