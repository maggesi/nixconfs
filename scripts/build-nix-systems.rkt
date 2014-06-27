#lang racket

(define system-bin-path
  (string->path "/run/current-system/sw/bin"))

(define nixos-channel-path
  (string->path "/nix/var/nix/profiles/per-user/root/channels/nixos/nixos"))

(define nix-build-path
  (build-path system-bin-path (string->path-element "nix-build")))

(define (run-nix-build . args)
  (apply system* nix-build-path args))

(define (nix-build-system configuration)
  (run-nix-build
   (build-path nixos-channel-path (string->path-element "default.nix"))
   "-k"
   "-j" "1"
   "--arg" "configuration" configuration
   "-A" "system"))

(with-output-to-string
 (lambda () (nix-build-system "/home/maggesi/Devel/nixconfs/neve/configuration.nix")))

(with-output-to-string
 (lambda () (nix-build-system "/home/maggesi/Devel/nixconfs/elio/elio.nix")))