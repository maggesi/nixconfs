{ stdenv, fetchgit, writeScript, ocaml, camlp5 }:

let
  start_script = ''
    #!/bin/sh
    cd "$out/lib/hol_light"
    exec ${ocaml}/bin/ocaml -I \`${camlp5}/bin/camlp5 -where\` -init make.ml
  '';
in

stdenv.mkDerivation {
  name     = "hol_light-2016-04-30";

  src = fetchgit {
    url = "https://github.com/jrh13/hol-light/";
    rev = "1783c4a53841d6c93623a8eb99b8cd5d41ff0872";
    sha256 = "00piiiw78qz8m35gyfqyrsq7jzac251irja91c7kq182rfnz33ki";
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
