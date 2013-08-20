# Marco Maggesi http://www.math.unifi.it/~maggesi/

{stdenv, fetchgit, coq}:

stdenv.mkDerivation {
  name = "hott-2013-08-19";

  src = fetchgit {
    url = git://github.com/HoTT/HoTT.git;
    rev = "99227a73b190dee73b72d14b4a2ae03e7085e058";
    sha256 = "03aghdsbbzfayfqqyfys0x9y92xrgvgdnc55gpm3zickhhzv5qfr";
  };

  buildInputs = [ coq ];

  buildPhase = ''
    for i in hoqc.in hoqtop.in hoqide.in; do
      substituteInPlace $i --replace /bin/bash /bin/sh
    done
    ./configure
    make
  '';

  installPhase = ''
    ensureDir $out
    cp -a . $out/hott
  '';

  meta = with stdenv.lib; {
    description = "Homotopy Type Theory library for Coq";
    longDescription = ''
      The HoTT library is a development of homotopy-theoretic ideas in the Coq proof assistant.
    '';
    homepage = https://github.com/HoTT/HoTT;
    license = licenses.bsd2;
    platforms = coq.meta.platforms;
    maintainers = with maintainers; [ z77z ];
  };
}
