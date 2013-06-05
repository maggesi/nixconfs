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

;; COMMENTARY, INSTALLATION AND USAGE:
;;
;; Read instructions in the companion HOL-Light mode in file holl.el.

(require 'holl)
(require 'comint)

(defgroup inferior-holl nil
  "Run a HOL-Light process in a buffer."
  :group 'holl)

(defcustom inferior-holl-mode-hook nil
  "*Hook for customising `inferior-holl-mode'."
  :type 'hook
  :group 'holl)

(defcustom holl-program-name "hol"
  "*How HOL-Light is invoked."
  :type 'string
  :group 'holl)

(defvar inferior-holl-mode-map
  (let ((m (make-sparse-keymap)))
    (define-key m "\C-c\C-r" 'holl-send-region)
    (define-key m "\C-c\C-e" 'holl-send-phrase)
    (define-key m "\C-c\C-g" 'holl-send-goal)
    (define-key m "\C-c\C-t" 'holl-send-tactic)
    (define-key m "\C-c\C-b" 'holl-send-backup)
    (define-key m "\C-c\C-p" 'holl-send-print)
    m))

;; Install the process communication commands in the holl-mode keymap.
(define-key holl-mode-map [(meta return)] 'holl-send-phrase)
(define-key holl-mode-map "\C-c\C-i" 'holl-display-inferior)
(define-key holl-mode-map "\C-c\C-r" 'holl-send-region)
(define-key holl-mode-map "\C-c\C-g" 'holl-send-goal)
(define-key holl-mode-map "\C-c\C-e" 'holl-send-phrase)
(define-key holl-mode-map "\C-c\C-t" 'holl-send-tactic)
(define-key holl-mode-map "\C-c\C-b" 'holl-send-backup)
(define-key holl-mode-map "\C-c\C-p" 'holl-send-print)

(defvar holl-buffer nil "*The current holl process buffer.")

(define-derived-mode inferior-holl-mode comint-mode "Inferior HOL-Light"
  "\
Major mode for interacting with an inferior HOL-Light process.

A HOL-Light process can be fired up with M-x run-holl.

Customisation: Entry to this mode runs the hooks on comint-mode-hook
and inferior-holl-mode-hook (in that order).

You can send text to the inferior HOL-Light process from other buffers
containing HOL-Light source.

The following commands are available:
\\{inferior-holl-mode-map}
"
  ;; Customise in inferior-holl-mode-hook
  (setq comint-prompt-regexp "^# ?")
  (holl-mode-variables)
  (setq mode-line-process '(":%s"))
  (set (make-local-variable 'font-lock-defaults) '(holl-font-lock-keywords))
  )

(defun holl-args-to-list (string)
  (let ((where (string-match "[ \t]" string)))
    (cond ((null where) (list string))
	  ((not (= where 0))
	   (cons (substring string 0 where)
		 (holl-args-to-list (substring string (+ 1 where)
						 (length string)))))
	  (t (let ((pos (string-match "[^ \t]" string)))
	       (if (null pos)
		   nil
		 (holl-args-to-list (substring string pos
						 (length string)))))))))

;;;###autoload
(defun run-holl (cmd)
  "Run an inferior HOL-Light process, input and output via buffer *holl*.
If there is a process already running in `*holl*', switch to that buffer.
With argument, allows you to edit the command line (default is value
of `holl-program-name').  Runs the hooks `inferior-holl-mode-hook'
\(after the `comint-mode-hook' is run).
\(Type \\[describe-mode] in the process buffer for a list of commands.)"

  (interactive (list (if current-prefix-arg
			 (read-string "Run HOL-Light: " holl-program-name)
			 holl-program-name)))
  (if (not (comint-check-proc "*holl*"))
      (let ((cmdlist (holl-args-to-list cmd)))
	(set-buffer (apply 'make-comint "holl" (car cmdlist)
			   nil (cdr cmdlist)))
	(inferior-holl-mode)))
  (setq holl-program-name cmd)
  (setq holl-buffer "*holl*")
  (switch-to-buffer "*holl*"))

;;;###autoload
(defun run-holl-other-window (cmd)
  "Run an inferior HOL-Light process, input and output via buffer *holl*.
If there is a process already running in `*holl*', switch to that buffer.
With argument, allows you to edit the command line (default is value
of `holl-program-name').  Runs the hooks `inferior-holl-mode-hook'
\(after the `comint-mode-hook' is run).
\(Type \\[describe-mode] in the process buffer for a list of commands.)"

  (interactive (list (if current-prefix-arg
			 (read-string "Run HOL-Light: " holl-program-name)
			 holl-program-name)))
  (if (not (comint-check-proc "*holl*"))
      (let ((cmdlist (holl-args-to-list cmd)))
	(set-buffer (apply 'make-comint "holl" (car cmdlist)
			   nil (cdr cmdlist)))
	(inferior-holl-mode)))
  (setq holl-program-name cmd)
  (setq holl-buffer "*holl*")
  (display-buffer "*holl*"))
;;;###autoload (add-hook 'same-window-buffer-names "*holl*")

(defun run-holl-other-frame (cmd)
  "Run an inferior HOL-Light process, input and output via buffer *holl*.
If there is a process already running in `*holl*', switch to that buffer.
With argument, allows you to edit the command line (default is value
of `holl-program-name').  Runs the hooks `inferior-holl-mode-hook'
\(after the `comint-mode-hook' is run).
\(Type \\[describe-mode] in the process buffer for a list of commands.)"

  (interactive (list (if current-prefix-arg
			 (read-string "Run HOL-Light: " holl-program-name)
			 holl-program-name)))
  (if (not (comint-check-proc "*holl*"))
      (let ((cmdlist (holl-args-to-list cmd)))
	(set-buffer (apply 'make-comint "holl" (car cmdlist)
			   nil (cdr cmdlist)))
	(inferior-holl-mode)))
  (setq holl-program-name cmd)
  (setq holl-buffer "*holl*")
  (switch-to-buffer-other-frame "*holl*"))

(defun holl-display-inferior (select)
  "Display the buffer of the inferior holl process.  With argument,
select the buffer"
  (interactive "P")
  (if (get-buffer holl-buffer)
      (if select
	  (pop-to-buffer holl-buffer)
	(display-buffer holl-buffer nil t))
    (error "No current process buffer.  See variable `holl-buffer'")))

(defun holl-send-region (start end)
  "Send the current region to the inferior HOL-Light process."
  (interactive "r")
  (comint-send-region (holl-proc) start end)
  (holl-display-inferior nil))

(defun holl-send-line ()
  "Send the current line to the inferior HOL-Light process."
  (interactive)
  (save-excursion
    (beginning-of-line)
    (let ((start (point)))
      (end-of-line)
      (holl-send-region start (point))
      (holl-send-string "\n"))))

(defun holl-send-tactic ()
  (interactive)
  (save-excursion
    (re-search-backward "^[[:space:]]*$\\|\\`")
    (forward-line)
    (let ((start (point)))
      (re-search-forward "^[[:space:]]*$\\|\\'")
      (backward-char)
      (skip-chars-backward "[:space:]")
      (if (looking-back "THENL?")
	  (progn
	    (goto-char (match-beginning 0))
	    (skip-chars-backward "[:space:]")))
      (holl-send-string "e (")
      (holl-send-region start (point))
      (holl-send-string ");;\n"))))

(defun holl-send-string (string)
  "Send a string to the inferior HOL-Light process."
  (comint-send-string (holl-proc) string))

(defun holl-send-goal ()
  "Send region as goal to HOL."
  (interactive)
  (holl-mark-term)
  (save-excursion
    (holl-send-string "g ")
    (holl-send-region (point) (mark))
    (holl-send-string ";;\n")))

(defun holl-send-phrase ()
  "Send phrase at point to the HOL-Light process."
  (interactive)
  (skip-chars-backward " \t;")
  (unless (holl-search-double-semicolon-forward 1)
    (error "Cannot find end of phrase"))
  (save-excursion
    (let ((end (point)))
      (holl-phrase-backward)
      (holl-send-region (point) end)
      (holl-send-string ";;\n")))
  (skip-chars-forward " \t")
  ;; Try to move after a newline
  (let ((match (re-search-forward "\\=[ \t]*\n?" nil t)))
    (and match (goto-char match))))

(defun holl-send-command (cmd)
  "Send a single command to the inferior HOL-Light process."
  (interactive "M")
  (comint-send-string (holl-proc) cmd)
  (holl-send-string ";;\n")
  (display-buffer holl-buffer))

(defun holl-send-print ()
  "Send \"p()\" command to HOL-Light process."
  (interactive)
  (holl-send-command "p()"))

(defun holl-send-backup ()
  "Send \"b()\" command to HOL-Light process."
  (interactive)
  (holl-send-command "b()"))

(defun holl-proc ()
  "Return the current holl process.  See variable `holl-buffer'."
  (let ((proc (get-buffer-process (if (eq major-mode 'inferior-holl-mode)
				      (current-buffer)
				      holl-buffer))))
    (or proc
	(error "No current process.  See variable `holl-buffer'"))))

(defcustom inferior-holl-load-hook nil
  "This hook is run when inferior-holl is loaded in.
This is a good place to put keybindings."
  :type 'hook
  :group 'inferior-holl)
	
(run-hooks 'inferior-holl-load-hook)

(provide 'inferior-holl)
