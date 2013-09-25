# - coqide compilation can be disabled by setting lablgtk to null;

{stdenv, fetchgit, pkgconfig, ocaml, findlib, camlp5, ncurses, lablgtk ? null}:

let 
  version = "2013-07-31";
  buildIde = lablgtk != null;
  ideFlags = if buildIde then "-lablgtkdir ${lablgtk}/lib/ocaml/*/site-lib/lablgtk2 -coqide opt" else "";
  idePath = if buildIde then ''
    CAML_LD_LIBRARY_PATH=${lablgtk}/lib/ocaml/3.12.1/site-lib/stublibs
  '' else "";
in

stdenv.mkDerivation {
  name = "coq_hott-${version}";

  src = fetchgit {
    url = git://github.com/HoTT/coq.git;
    rev = "e88e47ca76200a5e52bd0f9397fe4900fa9b241b";
    sha256 = "0aa8pi3yz76qw4ql2fcg3plgvhzkl2x84ama5w7lvww2dk909vqh";
  };

  buildInputs = [ pkgconfig ocaml findlib camlp5 ncurses lablgtk ];

  patches = [ ./configure.patch ];

  postPatch = ''
    UNAME=$(type -tp uname)
    RM=$(type -tp rm)
    substituteInPlace configure --replace "/bin/uname" "$UNAME"
    substituteInPlace tools/beautify-archive --replace "/bin/rm" "$RM"
  '';

  preConfigure = ''
    buildFlagsArray=(${idePath})
    configureFlagsArray=(
      -opt
      -camldir ${ocaml}/bin
      -camlp5dir $(ocamlfind query camlp5)
      ${ideFlags}
    )
  '';

  prefixKey = "-prefix ";

  #buildFlags = "coqlight";
  buildFlags = "revision coq coqide";

  meta = with stdenv.lib; {
    description = "Coq proof assistant";
    longDescription = ''
      Coq is a formal proof management system.  It provides a formal language
      to write mathematical definitions, executable algorithms and theorems
      together with an environment for semi-interactive development of
      machine-checked proofs.
    '';
    homepage = http://coq.inria.fr;
    license = licenses.lgpl21Plus;
    platforms = with platforms; unix ++ darwin;
    maintainers = with maintainers; [ roconnor z77z ];
  };
}
