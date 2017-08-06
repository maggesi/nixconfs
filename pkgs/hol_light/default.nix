{ stdenv, fetchgit, writeScript, ocaml, camlp5 }:

let
  start_script = ''
    #!/bin/sh
    cd "$out/lib/hol_light"
    exec ${ocaml}/bin/ocaml -I \`${camlp5}/bin/camlp5 -where\` -init make.ml
  '';
in

stdenv.mkDerivation {
  name = "hol_light-2017-06-25";

  src = fetchgit {
    url = https://github.com/jrh13/hol-light/;
    rev = "7e0e1d43826919a8dee84c8a66d3d43fa1a9bcd8";
    sha256 = "0h57qr7hbjzhf60s2i2pc91rnn02kj0a0dl2x37xjddgmy855v4k";
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
