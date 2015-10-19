{ stdenv, cr_restart ? /run/current-system/sw/bin/cr_restart }:

stdenv.mkDerivation rec {
  name     = "zcr_restart-2015-09-18";

  buildCommand = ''
    mkdir -p "$out/bin"
    dest="$out/bin/zcr_restart"
    cat ${./zcr_restart} > "$dest"
    substituteInPlace "$dest" --replace 'CR_RESTART_PATH' '${cr_restart}'
    chmod +x "$dest"
  '';

  meta = {
    description = "Restart BLCR checkpoint gzipped contexts.";
  };
}
