#lang racket

(define (git-repository? path)
  (directory-exists? (build-path path (string->path ".git"))))

(define git-executable (find-executable-path "git"))

(unless git-executable
  (error "Cannot find git executable in path"))

(define (run-git . args)
  (apply system* git-executable args))

(define start-path
  (build-path (find-system-path 'home-dir)
              (string->path "Devel")))

(define (find-git-repository start-path)
  (for ([path (in-directory start-path
                            (lambda (p) (not (git-repository? p))))])
    (when (git-repository? path)
      (printf "------------------------------------------------------------~n")
      (printf "~a~n" path)
      (run-git "-C" (path->string path) "fetch" "--all" "--prune")
      (run-git "-C" (path->string path) "status" "--porcelain")
      (run-git "-C" (path->string path) "pull" "--ff-only")
      (printf "~n"))))

(module+ test
  (find-git-repository start-path))