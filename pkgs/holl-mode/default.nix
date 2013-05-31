# Marco Maggesi http://www.math.unifi.it/~maggesi/

{stdenv, fetchurl, emacs}:

stdenv.mkDerivation {
  name = "holl-mode-20071214";
  #src = ./holl-mode-20071214.tbz2;
  src = ./holl-mode-20071214-fix;

  buildInputs = [ emacs ];

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
