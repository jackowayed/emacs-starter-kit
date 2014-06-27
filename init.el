;;; init.el --- Where all the magic begins
;;
;; Part of the Emacs Starter Kit
;;
;; This is the first thing to get loaded.
;;
;; "Emacs outshines all other editing software in approximately the
;; same way that the noonday sun does the stars. It is not just bigger
;; and brighter; it simply makes everything else vanish."
;; -Neal Stephenson, "In the Beginning was the Command Line"

;; Turn off mouse interface early in startup to avoid momentary display
;; You really don't need these; trust me.
(if (fboundp 'menu-bar-mode) (menu-bar-mode -1))
(if (fboundp 'tool-bar-mode) (tool-bar-mode -1))
(if (fboundp 'scroll-bar-mode) (scroll-bar-mode -1))

;; Load path etc.

(setq dotfiles-dir (file-name-directory
                    (or (buffer-file-name) load-file-name)))

;; Load up ELPA, the package manager

(add-to-list 'load-path dotfiles-dir)

(require 'package)
(add-to-list 'package-archives
             '("melpa" . "http://melpa.milkbox.net/packages/") t)
(add-to-list 'package-archives
             '("marmalade" . "http://marmalade-repo.org/packages/"))
(package-initialize)
(require 'starter-kit-elpa)

(add-to-list 'load-path (concat dotfiles-dir "/elpa-to-submit"))

(setq autoload-file (concat dotfiles-dir "loaddefs.el"))
(setq package-user-dir (concat dotfiles-dir "elpa"))
(setq custom-file (concat dotfiles-dir "custom.el"))

;; These should be loaded on startup rather than autoloaded on demand
;; since they are likely to be used in every session

(require 'cl)
(require 'saveplace)
(require 'ffap)
(require 'uniquify)
(require 'ansi-color)

;; backport some functionality to Emacs 22 if needed
(require 'dominating-file)

;; Load up starter kit customizations

(require 'starter-kit-defuns)
(require 'starter-kit-bindings)
(require 'starter-kit-misc)
(require 'starter-kit-registers)
(require 'starter-kit-eshell)
(require 'starter-kit-lisp)
(require 'starter-kit-perl)
(require 'starter-kit-ruby)
(require 'starter-kit-js)

(regen-autoloads)
(load custom-file 'noerror)

;; You can keep system- or user-specific customizations here
(setq system-specific-config (concat dotfiles-dir system-name ".el")
      user-specific-config (concat dotfiles-dir user-login-name ".el")
      user-specific-dir (concat dotfiles-dir user-login-name))
(add-to-list 'load-path user-specific-dir)

(if (file-exists-p system-specific-config) (load system-specific-config))
(if (file-exists-p user-specific-config) (load user-specific-config))
(if (file-exists-p user-specific-dir)
  (mapc #'load (directory-files user-specific-dir nil ".*el$")))

;;; init.el ends here


; for loading libraries in from the vendor directory
; shamelessly stolen from http://github.com/defunkt/emacs
(defun vendor (library)
  (let* ((file (symbol-name library))
         (normal (concat "~/.emacs.d/vendor/" file))
         (suffix (concat normal ".el"))
         (defunkt (concat "~/.emacs.d/defunkt/" file)))
    (cond
     ((file-directory-p normal) (add-to-list 'load-path normal) (require library))
     ((file-directory-p suffix) (add-to-list 'load-path suffix) (require library))
     ((file-exists-p suffix) (require library)))
    (when (file-exists-p (concat defunkt ".el"))
      (load defunkt))))
(add-to-list 'load-path "~/.emacs.d/vendor")



(vendor 'textmate)
(textmate-mode)

(vendor 'open-file-in-github)


(setq org-agenda-files (list "~/org/life.org"
                             "~/org/to_read.org")
      org-mobile-force-id-on-agenda-items nil)

;; Kills all them buffers except scratch
;; optained from http://www.chrislott.org/geek/emacs/dotemacs.html
(defun nuke-all-buffers ()
  "kill all buffers, leaving *scratch* only"
  (interactive)
  (mapcar (lambda (x) (kill-buffer x))
	  (buffer-list))
  (delete-other-windows))

(require 'color-theme)
(require 'dark-theme)
(dark-theme)


(add-to-list 'load-path "~/.emacs.d/vendor/coffee-mode")
(require 'coffee-mode)
(add-to-list 'auto-mode-alist '("\\.coffee$" . coffee-mode))
(add-to-list 'auto-mode-alist '("Cakefile" . coffee-mode))



(defun split-dedicated-window (b size)
  (interactive "BBuffer: \nNLines to show: ")
  (split-window (selected-window) (+ size 2))
  (set-window-buffer (selected-window) b)
  (set-window-dedicated-p (selected-window) t))

;(server-start)

;; Turn on tabs
;(setq indent-tabs-mode t)
;(setq-default indent-tabs-mode t)

;; Bind the TAB key 
;(global-set-key (kbd "TAB") 'self-insert-command)

;; Set the tab width
(setq default-tab-width 2)
(setq tab-width 2)
(setq c-basic-indent 2)


(custom-set-variables
    '(ispell-dictionary "en_US")
    '(ispell-program-name "/usr/local/bin/aspell"))

(setq org-mobile-directory "~/Dropbox/mobileorg")
(setq org-directory "~/Dropbox/org")
(setq org-mobile-inbox-for-pull "~/Dropbox/mobileorginbox/")

;(require 'ess-site)

(server-start)

(add-hook
 'org-mode-hook
 '(lambda ()
    (add-hook
     'after-save-hook
     'org-mobile-push
     t t)))

(add-hook
 'org-mode-hook
 (lambda () (setq truncate-lines nil)))

; http://definitelyaplug.b0.cx/post/custom-inlined-css-in-org-mode-html-export/
(defun my-org-inline-css-hook (exporter)
  "Insert custom inline css"
  (when (eq exporter 'html)
    (let* ((dir (ignore-errors (file-name-directory (buffer-file-name))))
           (path (concat dir "style.css"))
           (homestyle (or (null dir) (null (file-exists-p path))))
           (final (if homestyle "~/.emacs.d/org-style.css" path)))
      (setq org-html-head-include-default-style nil)
      (setq org-html-head (concat
                           "<style type=\"text/css\">\n"
                           "<!--/*--><![CDATA[/*><!--*/\n"
                           (with-temp-buffer
                             (insert-file-contents final)
                             (buffer-string))
                           "/*]]>*/-->\n"
                           "</style>\n")))))

(eval-after-load 'ox
  '(progn
     (add-hook 'org-export-before-processing-hook 'my-org-inline-css-hook)))



(setq sentence-end-double-space nil)

; http://www.emacswiki.org/emacs/IbufferMode
(require 'ibuffer)
(setq ibuffer-saved-filter-groups
      (quote (("default"
               ("org" (mode . org-mode))
               ("R" (or
                     (mode . r-mode)
                     (mode . ess-mode)
                     (name . "^\\*ESS\\*$")))
               ("emacs" (or
                         (name . "^\\*scratch\\*$")
                         (name . "^\\*Messages\\*$")))))))

(add-hook 'ibuffer-mode-hook
          (lambda ()
            (ibuffer-switch-to-saved-filter-groups "default")))

(global-set-key (kbd "C-x C-b") 'ibuffer)

(defun system-copy-region ()
  "Use pbcopy to copy the region on Mac"
  (interactive)
  (shell-command-on-region (min (mark) (point)) (max (mark) (point)) "pbcopy"))

(global-set-key (kbd "C-c C-d") 'system-copy-region)

(vendor 'word-count-race)

(global-set-key (kbd "M-g s") 'magit-status)

(require 'haml-mode)

(setq vc-follow-symlinks t)

(recentf-mode 0)

(global-set-key (kbd "M-RET") 'ns-toggle-fullscreen)

(setq mac-option-key-is-meta nil)
(setq mac-command-key-is-meta t)
(setq mac-command-modifier 'meta)
(setq mac-option-modifier nil)


(global-set-key (kbd "M-T") 'textmate-goto-symbol)

(require 'go-mode-load)

(setq sentence-end-double-space nil)

(column-number-mode)

(setq c-default-style "linux"
      c-basic-offset 4)

(global-set-key (kbd "C-z") 'keyboard-quit)

; http://www.emacswiki.org/emacs/WordCount
    ;; source: xemacs 20.3
    (defun count-words-region (start end)
       (interactive "r")
       (save-excursion
          (let ((n 0))
           (goto-char start)
           (while (< (point) end)
             (if (forward-word 1)
                 (setq n (1+ n))))
           (message "Region has %d words" n)
           n)))

(require 'ido-vertical-mode)
(ido-mode 1)
(ido-vertical-mode 1)


;(add-hook 'after-init-hook 'global-company-mode)
(global-set-key (kbd "<C-tab>") 'company-complete)

;(add-hook 'before-save-hook 'gofmt-before-save)
;(add-to-list 'load-path "~/code/go/src/github.com/dougm/goflymake")
;(require 'go-flymake)
;(require 'go-flycheck)
;(add-to-list 'load-path "~/code/go/src/github.com/nsf/gocode/emacs-company")
;(require 'company-go)
;(add-hook 'go-mode-hook (lambda ()
;                          (set (make-local-variable 'company-backends) '(company-go))
;                          (company-mode)))

(setq c-basic-indent 2)
(setq truncate-lines nil)
