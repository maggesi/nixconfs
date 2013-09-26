(autoload 'holl-mode "holl" "Major mode for editing HOL Light scripts." t)
(autoload 'run-holl "inferior-holl" "Run HOL Light inside emacs." t)
(add-to-list 'auto-mode-alist '("\\.hl\\'" . holl-mode) auto-mode-alist)
(provide 'holl-conf)
