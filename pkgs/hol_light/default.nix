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
  name     = "hol_light-2019-03-10";

  src = fetchFromGitHub {
    owner  = "jrh13";
    repo   = "hol-light";
    rev    = "4f1dfbd8c9a072cce84f65f9f1deea563a5ca4ee";
    sha256 = "0rafnc3c7ax2lyz3c43hm4xf3kqxmabvvvql66s2axrfl4sdgbfz";
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
