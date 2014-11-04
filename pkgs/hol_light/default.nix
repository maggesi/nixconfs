{ stdenv, fetchsvn, writeScript, ocaml, findlib, camlp5 }:

let
  start_script = ''
    #!/bin/sh
    cd "$out/lib/hol_light"
    exec ${ocaml}/bin/ocaml -I \`${camlp5}/bin/camlp5 -where\` -init make.ml
  '';
in

stdenv.mkDerivation rec {
  name     = "hol_light-${version}";
  version  = "203";

  src = fetchsvn {
    url = http://hol-light.googlecode.com/svn/trunk;
    rev = version;
    sha256 = "0n62sk2w0yk3qjjzrmfgkiknh25nb8s6izz166q6fnwhic6m5rxy";
  };

  buildInputs = [ ocaml findlib camlp5 ];

  patches = [ ./Makefile.patch ];

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
