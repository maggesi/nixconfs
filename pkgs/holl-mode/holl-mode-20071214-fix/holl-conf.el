(autoload 'holl-mode "@hollPath@/holl" "Major mode for editing HOL Light scripts." t)
(autoload 'run-holl "@hollPath@/inferior-holl" "Run HOL Light inside emacs." t)
(add-to-list 'auto-mode-alist '("\\.hl\\'" . holl-mode) auto-mode-alist)
(provide 'holl-conf)
