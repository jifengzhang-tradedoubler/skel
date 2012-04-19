;; Define C-, and C-. as scoll-up and scroll-down
(defun scroll-up-one-line ()
  (interactive)
  (scroll-up 1))
(defun scroll-down-one-line ()
  (interactive)
  (scroll-down 1))
(defun scroll-other-window-up-one-line ()
  (interactive)
  (scroll-other-window 1))
(defun scroll-other-window-down-one-line ()
  (interactive)
  (scroll-other-window -1))
(global-set-key [?\C-,] 'scroll-up-one-line)
(global-set-key [?\C-.] 'scroll-down-one-line)
(global-set-key [?\C-\;] 'scroll-other-window-up-one-line)
(global-set-key [?\C-:] 'scroll-other-window-down-one-line)


; Define function to match a parenthesis otherwise insert a %
(global-set-key "%" 'match-paren)
(defun match-paren (arg)
  "Go to the matching parenthesis if on parenthesis otherwise insert %."
  (interactive "p")
  (cond ((looking-at "\\s\(") (forward-list 1) (backward-char 1))
        ((looking-at "\\s\)") (forward-char 1) (backward-list 1))
        (t (self-insert-command (or arg 1)))))

(defun copy-file-name ()
  (interactive)
  (kill-new (buffer-file-name)))
(global-set-key "\C-xac" 'copy-file-name)

;; (looking-at "\\>") means "at end of word"
;; (looking-at "$") means "at end of line"
(defun indent-or-complete ()
  "Complete if point is at end of a word, and indent line."
  (interactive)
  (if (looking-at "\\>")
;;  (if (and (looking-at "$") (not (looking-back "^\\s-*")))
      (dabbrev-expand nil)
    (indent-for-tab-command)))

(add-hook 'c-mode-common-hook
	  (function (lambda ()
		      (local-set-key (kbd "<tab>") 'indent-or-complete))))

;; This is NOT working
(defun div-num ()
  "Push the number at point divided by 12 to the kill-ring."
  (interactive)
  (let (num)
    (save-excursion
      (forward-word 1)
      (set-mark-command (point))
      (backward-word)
      (copy-region-as-kill (point) (mark))
      (setq num (string-to-number (car kill-ring)))
      (push (/ num 12) kill-ring))))

(defun switch-window-buffers ()
  "Visit buffer of other window in this window and visit this buffer in other window."
  (interactive)
  (other-window 1)
  (switch-to-buffer (other-buffer (current-buffer) t))
  (other-window -1)
  (switch-to-buffer (other-buffer)))
(global-set-key "\C-xws" 'switch-window-buffers)

(defun erase-or-fill-to-column (col)
  "Move point and rest of line after point to COL, inserting spaces or backspaces as needed."
  (interactive "NColumn: ")
  (let ((diff (- col (current-column))))
    (if (< diff 0)
	(delete-backward-char (- diff))
      (insert-char 32 diff))))

;; (require 'java-mode-indent-annotations)
(defun fix-java-annotation-indentation ()
  (lambda () "Treat Java 1.5 @-style annotations as comments."
    (setq c-comment-start-regexp "(@|/(/|[*][*]?))")
    (modify-syntax-entry ?@ "< b" java-mode-syntax-table)))

(defun copy-word ()
  "Copy word to the left of point to kill-ring."
  (interactive)
  (save-excursion
    (backward-word)
    (push-mark)
    (forward-word)
    (kill-new (buffer-substring (mark) (point)))))
;;(<global-set-key "\C-x\C-g" 'copy-word)


;; Highlight word on double-click.

;;(setq *highlight-strings* '())
(defvar *highlight-strings* '())

(defun highlit (word)
  (member word *highlight-strings*))

(defun highlight-word (word)
  (interactive)
  (unless (highlit word)
    (push word *highlight-strings*))
  (highlight-regexp (thing-at-point 'word)))

(defun unhighlight-word (word)
  (interactive)
  (setq *highlight-strings* (remove word *highlight-strings*))
  (unhighlight-regexp word))

(defun highlight-word-at-point ()
  (interactive)
  (let ((word (thing-at-point 'word)))
    (if (highlit word)
	(unhighlight-word word)
      (highlight-word word))))
(global-set-key '[double-mouse-1] 'highlight-word-at-point)

(defun downcase-char ()
  (interactive)
  (save-excursion
    (push-mark (point))
    (forward-char)
    (downcase-region (mark) (point)))
  (forward-char))

;; (defun upcase-lowcase-region ()
;;   "Capitalize a region"
;;   (interactive)
;;   (push-mark (point))
;;   (search-forward-regexp "[A-Z0-9 ]")
;;   (upcase-region (mark) (point))
;;   (char-after (point)))

;; (defun variable-to-constant ()
;;   (interactive)
;;   (save-excursion
;;     (while (upcase-lowcase-region



;;(add-hook 'find-file-hook
;;	  (lambda ()
;;	    (highlight-regexp "qwerty")))


;;	    (font-lock-add-keywords nil
;;				    '(("\\<\\(FIXME\\|TODO\\|NOTE\\|BUG|QWERTY\\):" 1 font-lock-warning-face prepend)))))

(defun switch-to-previous-buffer ()
  "Switch to previously active buffer."
  (interactive)
  (switch-to-buffer nil))
(global-set-key (kbd "<backtab>") 'switch-to-previous-buffer)

(defun backward-other-window ()
  "Switch focus to other window, backwards."
  (interactive)
  (other-window -1))
(global-set-key (kbd "<C-tab>") 'other-window)
(global-set-key (kbd "<S-C-iso-lefttab>") 'backward-other-window)


(defun toggle-fold ()
  "Toggle fold all lines larger than indentation on current line"
  (interactive)
  (let ((col 1))
    (save-excursion
      (back-to-indentation)
      (setq col (+ 1 (current-column)))
      (set-selective-display
       (if selective-display nil (or col 1))))))
(global-set-key [(M C i)] 'toggle-fold)


(defun java-string-to-sql ()
  (interactive)
  (replace-regexp "^[ =+]*\"" "" nil (point-min) (point-max))
  (replace-regexp "\"[ ;+]*$" "" nil (point-min) (point-max))
  (delete-trailing-whitespace))

(defun ps-print-buffer-landscape ()
  "Use ps-print-buffer to print the buffer in landscape mode."
  (interactive)
  (setq ps-landscape-mode t)
  (ps-print-buffer)
  (setq ps-landscape-mode 'nil))

(defun jon-compile ()
  (interactive)
  (if (eq (next-window) (selected-window))
      (compile "m -k")
    (lambda ()
      (other-window 1)
      (switch-to-buffer '*compilation*)))
  (other-window 1)
  (compile "m -k"))
