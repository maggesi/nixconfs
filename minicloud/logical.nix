# Logical network specification for my "minicloud".
{
  network.description = "Web server";

  webserver = 
    { config, pkgs, ... }:
    { services.httpd.enable = true;
      services.httpd.adminAddr = "alice@example.org";
      services.httpd.documentRoot = "${pkgs.valgrind}/share/doc/valgrind/html";
    };
}
