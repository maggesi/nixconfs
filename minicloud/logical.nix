# Logical network specification for my "minicloud".

{
  network.description = "Web server";

  webserver = 
    { config, pkgs, ... }:
    {
      require = [ <nixos/modules/programs/virtualbox.nix> ];
      services.httpd.enable = true;
      services.httpd.adminAddr = "marco.maggesi@unifi.it";
      services.httpd.documentRoot = "${pkgs.valgrind}/share/doc/valgrind/html";
      environment.systemPackages =
        with pkgs;
        [
          emacs
	  mc
	  screen
	  tmux
        ];
    };

/*
  patripatan = 
    { config, pkgs, ... }:
    {
      environment.blcr.enable = true;
      environment.systemPackages =
        with pkgs;
        [
          emacs
	  mc
	  ocaml
	  screen
	  tmux
        ];
    };
*/
}
