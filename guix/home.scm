(use-modules (gnu home)
             (gnu home services)
             (gnu packages)
	     (gnu services)
	     (gnu packages emacs)
             (gnu packages emacs-xyz)
             (gnu packages fonts)
             (gnu packages python)
             (gnu packages node)
             (gnu packages tex)
             (gnu packages version-control)
	     (gnu packages haskell-xyz)
	     (gnu packages python-xyz)
	     (gnu packages texlive)
	     (guix transformations)
	     (guix packages)
	     (srfi srfi-1)
             (guix build-system emacs)
	     (guix build-system gnu)
	     (guix build-system copy)
	     (packages ai)
	     (packages ensure-guix)
	     (gnu packages networking)
	     (gnu packages mail)
	     (gnu packages curl)
	     ;; (gnu home services desktop)
	     ;; (gnu services desktop)
	     )


(define transform-gptel
  (options->transformation
   '((with-commit . "emacs-gptel=075376c002d0f0c50e68ffd23c647eeab27fea73"))))

(define gptel-package
  (transform-gptel emacs-gptel))

(define gptel-without-compilation
  (package
   (inherit emacs-gptel)
   (build-system copy-build-system)
   (arguments
    `(#:install-plan
      '(("." "share/emacs/site-lisp/"))))))  ;; Copy the entire directory

(home-environment
 (packages
  (list emacs-next
        emacs
	git
	emacs-use-package-ensure-guix
        emacs-ace-window
        emacs-all-the-icons
        emacs-atomic-chrome
        emacs-auto-yasnippet
        emacs-avy
        emacs-bug-hunter
        emacs-burly
        emacs-cape
        emacs-code-cells
        emacs-corfu
        emacs-counsel
        emacs-counsel-tramp
        emacs-dap-mode
        emacs-dash
        emacs-dashboard
        emacs-docker-tramp
        emacs-doom-modeline
        emacs-doom-themes
        emacs-easy-kill
        emacs-editorconfig
        emacs-elfeed
        emacs-eterm-256color
        emacs-evil-nerd-commenter
        emacs-exec-path-from-shell
        emacs-expand-region
        emacs-f
        emacs-flycheck
        emacs-fontaine
        emacs-general
        emacs-guix
        emacs-hide-lines
        emacs-hydra
        emacs-ivy
        emacs-ivy-rich
        emacs-ivy-yasnippet
        emacs-jsonrpc
        emacs-jupyter
        emacs-kind-icon
        emacs-lsp-ivy
        emacs-lsp-mode
        emacs-lsp-treemacs
        emacs-lsp-ui
        emacs-magit
        emacs-multiple-cursors
        emacs-no-littering
        emacs-org
        emacs-org-bullets
        emacs-org-chef
        emacs-org-download
        emacs-org-tree-slide
        emacs-ox-hugo
        emacs-page-break-lines
        emacs-perspective
        emacs-phi-search
        emacs-pretty-hydra
        emacs-projectile
        emacs-pyvenv
        emacs-restclient
        emacs-s
        emacs-sphinx-doc
        emacs-swiper
        emacs-transpose-frame
        emacs-use-package
        emacs-which-key
        emacs-yasnippet
        ;; font-aporetic
        font-iosevka
        font-iosevka-comfy
        node
        pandoc
        python
        python-jupytext
        python-lsp-server
	texlive
	emacs-transient
	emacs-copilot
	;; emacs-gptel
	gptel-without-compilation
	emacs-claude-code
	mu
	;; emacs-transient
	;; claude-code-cli
	;; (specification->package "claude-code-cli@0.1.0")
	;; ((options->transformation
	;;   '((with-commit . "emacs-gptel=2bb081e")))
	;;  emacs-gptel))
	blueman
	curl
	))
 ;; (services
 ;;  (list
 ;;   (simple-service
 ;;    'desktop-entries
 ;;    home-desktop-entries-service-type
 ;;    (list
 ;;     (desktop-entyr
 ;;      (name "Emacs")
 ;;      (exec "bash -l -c 'emacs %F'")
 ;;      (comment "GNU Emacs")
 ;;      (type "Application")
 ;;      (icon "emacs")
 ;;      (categories '("Development" "TextEditor"))
 ;;      (terminal #f))))))
 ;; )
)
