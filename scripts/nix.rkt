#lang racket/base

(provide run-nix-build
         run-nix-channel
         run-nix-collect-garbage
         run-nix-env)

(require racket/system)

(module+ test
  (require rackunit))

;; --------------------------------------------------------------------------------------------------
;; Helper functions.
;; --------------------------------------------------------------------------------------------------

(define (file-executable? path)
  (and (file-exists? path)
       (member 'execute (file-or-directory-permissions path))
       path))

#;(module+ test
  (check-equal? (file-executable? (find-executable-path "ls")) #t)
  (check-equal? (file-executable? (string->path "/etc/passwd")) #f))

;; --------------------------------------------------------------------------------------------------
;; Constants.
;; --------------------------------------------------------------------------------------------------

(define nixos-system-bin-path
  (string->path "/run/current-system/sw/bin"))

(define nix-bin-path
  (build-path (find-system-path 'home-dir)
              (string->path ".nix-profile/bin")))

;; --------------------------------------------------------------------------------------------------
;; Simple heuristics for determine the path of nix-commands:
;; - first search in the path;
;; - next search in the active system profile;
;; - finally search in the active user profile;
;; - raise an error otherwise.
;; --------------------------------------------------------------------------------------------------

(define (find-nix-command-path cmd)
  (define cmd-path (string->path-element cmd))
  (define found-in-path (find-executable-path cmd-path))
  (or found-in-path
      (findf file-executable?
             (map (lambda (root-path) (build-path root-path cmd-path))
                  (list nixos-system-bin-path
                        nix-bin-path)))))

(define-values
  (nix-build-path
   nix-channel-path
   nix-collect-garbage-path
   nix-env-path)
  (apply values
         (map find-nix-command-path
              (list "nix-build"
                    "nix-channel"
                    "nix-collect-garbage"
                    "nix-env"))))

(define (run-nix-build . args)
  (apply system* nix-build-path args))

(define (run-nix-collect-garbage . args)
  (apply system* nix-collect-garbage-path args))

(define (run-nix-channel . args)
  (apply system* nix-channel-path args))

(define (run-nix-env . args)
  (apply system* nix-env-path args))

(module+ test
  (check-true (run-nix-build "--version"))
  (check-true (run-nix-env "--version"))
  (check-true (run-nix-channel "--version"))
  (check-true (run-nix-collect-garbage "--version")))