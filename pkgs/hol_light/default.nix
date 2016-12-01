{ stdenv, fetchgit, writeScript, ocaml, camlp5 }:

let
  start_script = ''
    #!/bin/sh
    cd "$out/lib/hol_light"
    exec ${ocaml}/bin/ocaml -I \`${camlp5}/bin/camlp5 -where\` -init make.ml
  '';
in

stdenv.mkDerivation {
  name = "hol_light-2016-11-27";

  src = fetchgit {
    url = https://github.com/jrh13/hol-light/;
    rev = "6573d7767dd769890ff21f17050a4fd6c92d207c";
    sha256 = "0q8flbsn4hnimxlv4ci87yx4kjlkk5m1z1ilbgzmlbwgghjmidnh";
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
