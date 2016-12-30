{ stdenv, fetchgit, writeScript, ocaml, camlp5 }:

let
  start_script = ''
    #!/bin/sh
    cd "$out/lib/hol_light"
    exec ${ocaml}/bin/ocaml -I \`${camlp5}/bin/camlp5 -where\` -init make.ml
  '';
in

stdenv.mkDerivation {
  name = "hol_light-2016-12-18";

  src = fetchgit {
    url = https://github.com/jrh13/hol-light/;
    rev = "4f87e54ea7b074dfb9e45511a0d003e488f50be2";
    sha256 = "1n6d3fzjc5z35r2nmz1xqlfh2kwqr2v7r5jlwxkw5zd5bznsaw8r";
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
