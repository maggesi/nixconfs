# Marco Maggesi http://www.math.unifi.it/~maggesi/

{stdenv, fetchurl, emacs}:

let
  pname = "holl-mode";
  version = "20071214";
in

stdenv.mkDerivation {
  name = "${pname}-${version}";

  #src = "./${pname}-${version}.tbz2";
  src = ./holl-mode-20071214.tbz2;

  /*
  src = fetchurl {
    url = ./holl-mode-20071214.tbz2;
    sha256 = "012k2w2061x3biawv2drggcad1m43nq3frbz15nj0gj6cv1yp0y8";
  };
  */

  buildInputs = [ emacs ];

  patches = [ ./paths-fix.patch.gz ];

  postPatch = ''
    export hollPath="$out/share/emacs/site-lisp"
    substituteInPlace holl-conf.el --subst-var hollPath
  '';

  installPhase = ''
    echo "ensureDir $hollPath"
    echo "cp -a *.el.gz *.elc $hollPath"
    ensureDir $hollPath
    gzip -9 *.el
    cp -a *.el.gz *.elc $hollPath
  '';

  meta = {
    description = "HOL Light mode for emacs.";
    longDescription = ''
      A simple mode for editing and running HOL Light text proofs.
    '';
    homepage = http://www.math.unifi.it/~maggesi/;
    license = "ToDo";
  };
}
