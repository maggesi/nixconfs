#lang racket

(require "nix.rkt")

(module+ test
  (require rackunit))

(define nixos-channel-path
  (findf directory-exists?
         (list (string->path "/nix/var/nix/profiles/per-user/root/channels/nixos/nixos")
               (build-path (find-system-path 'home-dir)
                           (string->path ".nix-defexpr/channels/nixpkgs/nixos")))))

(module+ test
  (check-pred directory-exists?
              (build-path (find-system-path 'home-dir)
                          (string->path ".nix-defexpr/channels/nixpkgs/nixos"))))

(define (nix-build-system configuration)
  (run-nix-build
   (build-path nixos-channel-path (string->path-element "default.nix"))
   "-k"
   "-j" "1"
   "--arg" "configuration" configuration
   "-A" "system"))

#;(with-output-to-string
 (lambda ()
   (nix-build-system (build-path (find-system-path 'home-dir)
                                 (string->path "Devel/nixconfs/neve/configuration.nix")))))

#;(with-output-to-string
 (lambda ()
   (nix-build-system (build-path (find-system-path 'home-dir)
                                 (string->path "Devel/nixconfs/elio/elio.nix")))))

(with-output-to-string
 (lambda ()
   #;(run-nix-channel "--update")
   #;(run-nix-collect-garbage "--delete-older-than" "60d")
   #;(run-nix-env "--always" "-u" "*" "-b" "--keep-going")
   #;(run-nix-env "--always" "-u" "*" "--dry-run")
   (run-nix-env "--always" "-u" "*")
   ))
