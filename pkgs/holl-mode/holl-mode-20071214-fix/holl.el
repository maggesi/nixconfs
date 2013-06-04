;;; inferior-holl.el --- Run an inferior HOL-Light process.
;;; Version: 2006-09
;;; Copyright (C) Marco Maggesi (http://www.math.unifi.it/~maggesi/)
;;; Compatibility: Emacs21

;; LICENCE:
;;
;; This is free software; you can redistribute it and/or modify it under
;; the terms of the GNU General Public License as published by the Free
;; Software Foundation; either version 2, or (at your option) any later
;; version.
;;
;; This is distributed in the hope that it will be useful, but WITHOUT
;; ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
;; FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
;; for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs; see the file COPYING.  If not, write to the
;; Free Software Foundation, Inc., 59 Temple Place - Suite 330, Boston,
;; MA 02111-1307, USA.

;; COMMENTARY:
;;
;; This is a major mode for editing HOL-Light scripts.  HOL-Light is a
;; theorem prover written and mantained by John Harrison
;; (http://www.cl.cam.ac.uk/~jrh13/hol-light/).  The companion file
;; inferior-holl.el provides additional support to run HOL-Light in an
;; Emacs buffer and defines functions to send bits of code from other
;; buffers to the HOL-Light process.

;; INSTALLATION:
;;
;; Copy holl.el and inferior-holl.el somewhere in your load path, then add
;; the following code to your "~/.emacs":
;;
;; (autoload 'holl-mode "holl" "Major mode for editing HOL-Light scripts." t)
;; (autoload 'run-holl "inferior-holl" "Run HOL-Light inside emacs." t)

;; USAGE:
;;
;; When you load an HOL-Light script call `M-x holl-mode`.  You may
;; want to insert the string "(* -*- holl -*- *) in the first line of
;; your scripts so that emacs will select holl-mode automatically.
;; You can run HOL-Light inside Emacs with `M-x run-holl'.
;;
;; Functions and key bindings (Learn more keys with `C-c C-h' or `C-h m'):
;;
;;   M-return (`holl-send-line')    send the current line.


(defvar holl-mode-syntax-table
  (let ((st (make-syntax-table)))
    (modify-syntax-entry ?%  ".   " st)
    (modify-syntax-entry ?+  ".   " st)
    (modify-syntax-entry ?-  ".   " st)
    (modify-syntax-entry ?<  ".   " st)
    (modify-syntax-entry ?=  ".   " st)
    (modify-syntax-entry ?>  ".   " st)
    (modify-syntax-entry ?\" "\"  " st)
    (modify-syntax-entry ?\$ ".   " st)
    (modify-syntax-entry ?\& ".   " st)
    (modify-syntax-entry ?\' "w   " st)
    (modify-syntax-entry ?\( "()1n" st)
    (modify-syntax-entry ?\) ")(4n" st)
    (modify-syntax-entry ?\* ". 23n" st)
    (modify-syntax-entry ?\/ ".  " st)
    (modify-syntax-entry ?\\ "\\  " st)
    (modify-syntax-entry ?\| ".  " st)
    (modify-syntax-entry ?_  "_  " st)
    (modify-syntax-entry ?`  "$  " st)
    st)
  "Syntax table for `holl-mode'.")

(defvar holl-font-lock-keywords
  (list (cons (regexp-opt
	       '("and" "else" "end" "if" "in" "let" "rec" "match"
		 "then" "val" "with") 'words)
	      'font-lock-keyword-face))
  "Keyword highlighting specification for `holl-mode'.")

(defvar holl-mode-map
  (let ((km (make-sparse-keymap)))
    (define-key km [(meta return)] 'holl-send-phrase)
    (define-key km [(control return)] 'holl-send-phrase)
    (define-key km [(meta up)] 'holl-phrase-backward)
    (define-key km [(meta down)] 'holl-phrase-forward)
    (define-key km "\C-c\C-m" 'holl-mark-term)
    km)
  "Keymap used in HOL-Light mode.")

(autoload 'holl-send-phrase "inferior-holl"
  "Send the current phrase to the HOL-Light process."
  t)

(defvar holl-mode-hook nil
  "Hook for holl-mode")

(defun holl-indent-line ()
  "Indent a line in HOL-Light mode."
  (interactive)
  (let ((col (save-excursion
	       (forward-line -1)
	       (current-indentation))))
    (back-to-indentation)
    (if (> (current-column) col)
	(let ((pt (point)))
	  (move-to-column col)
	  (delete-region pt (point)))
      (indent-to col))))

(defun holl-mode-variables ()
  (set-syntax-table holl-mode-syntax-table)
  (set (make-local-variable 'paragraph-start)
       (concat "^$\\|" page-delimiter))
  (set (make-local-variable 'paragraph-separate) paragraph-start)
  (set (make-local-variable 'paragraph-ignore-fill-prefix) t)
  (set (make-local-variable 'require-final-newline) t)
  (set (make-local-variable 'comment-start) "(* ")
  (set (make-local-variable 'comment-end) " *)")
  (set (make-local-variable 'comment-column) 40)
  (set (make-local-variable 'comment-start-skip) "(\\*+ *")
  (set (make-local-variable 'parse-sexp-ignore-comments) nil)
  (set (make-local-variable 'indent-line-function) 'holl-indent-line))

(defun holl-mode ()
  "Major mode for editing HOL-Light code.
Tab at the beginning of a line indents this line like the line above.
Extra tabs increase the indentation level.  The variable
holl-mode-indentation indicates how many spaces are inserted for each
indentation level.

\\{holl-mode-map}"

  (interactive)
  (kill-all-local-variables)
  (setq major-mode 'holl-mode)
  (setq mode-name "holl")
  (use-local-map holl-mode-map)
  (holl-mode-variables)
  (make-local-variable 'font-lock-defaults)
  (setq font-lock-defaults '(holl-font-lock-keywords))
  (run-hooks 'holl-mode-hook))

(defun holl-mark-term ()
  "Select the a HOL term."
  (interactive)
  (let ((end
	 (save-excursion
	   (skip-chars-forward "^`")
	   (forward-char)
	   (point))))
    (skip-chars-backward "^`")
    (backward-char)
    (push-mark end nil t)))

(defun holl-search-double-semicolon-forward (&optional arg)
  "Search forward the N-th double semicolon \";;\" in a HOL-Light script.
If N is negative, search backward.  Stops right after it.  Skip
comments.  If N double semicolons are found as expected return t,
otherwise return nil."
  (interactive "p")
  (unless arg (setq arg 1))
  (if (< arg 0)
      (holl-search-double-semicolon-backward (- arg))
    (while (and (> arg 0)
		(re-search-forward "\\(;;\\)\\|\\(([*]\\)" nil t)
		(if (match-beginning 1)
		    (setq arg (1- arg))
		  (goto-char (match-beginning 2))
		  (forward-comment 1))))
    (= arg 0)))

(defun holl-search-double-semicolon-backward (&optional arg)
  "Search backward the N-th double semicolon \";;\" in a HOL-Light script.
If N is negative, search forward.  Stops right before it.  Skip
comments.  If N double semicolons are found as expected return t,
otherwise return nil."
  (interactive "p")
  (unless arg (setq arg 1))
  (if (< arg 0)
      (holl-search-double-semicolon-forward (- arg))
    (while (and (> arg 0)
		(re-search-backward "\\(;;\\)\\|\\([*])\\)" nil t)
		(if (match-beginning 1)
		    (setq arg (1- arg))
		  (goto-char (match-end 2))
		  (forward-comment -1))))
    (if (= arg 0) t
      (goto-char (point-min))
      nil)))

(defun holl-phrase-forward  (&optional arg)
  "Move forward across up to N HOL-Light phrases.
 If N is negative, move backward.  If N phrases are found as expected,
 return t; otherwise return nil."
  (interactive "p")
  (unless arg (setq arg 1))
  (if (< arg 0) (holl-phrase-backward (- arg))
    (when (and (> arg 0) (holl-search-double-semicolon-forward arg))
      (re-search-forward "\\=\n" nil t)
      t)))

(defun holl-phrase-backward  (&optional arg)
  "Move backward across up to N HOL-Light phrases.
 If N is negative, move forward.  If N phrases are found as expected,
 return t; otherwise return nil."
  (interactive "p")
  (unless arg (setq arg 1))
  (if (< arg 0)
      (holl-phrase-forward (- arg))
    (when (holl-search-double-semicolon-backward arg)
      (holl-search-double-semicolon-backward)
      (re-search-forward "\\=\\(;;\\)?\\s-*" nil t)
      (while (forward-comment 1))
      (skip-syntax-forward "-")
      t)))

(autoload 'run-holl "inferior-holl"
  "Run an inferior HOL-Light process." t)

;;; holl.el ends here

(provide 'holl)
