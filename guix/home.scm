(use-modules (gnu home)
             (gnu home services)
             (gnu packages)
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
	     (packages copilot)
	     (guix transformations)
	     (guix packages)
	     (srfi srfi-1)
             (guix build-system emacs)
	     )

(define transform-gptel
  (options->transformation
   '((with-commit . "emacs-gptel=2bb081e55e33b3df2b60d51d988713d9470e7d6c"))))

(define gptel-without-compilation
  (package
    (inherit (transform-gptel emacs-gptel))
    (build-system emacs-build-system)
    (arguments
     `(#:phases
       (modify-phases %standard-phases
         (delete 'byte-compile))))))

(home-environment
 (packages (list emacs
		 git
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
		 emacs-gptel
		 ;; gptel-without-compilation
		 ;; ((options->transformation
		 ;;   '((with-commit . "emacs-gptel=2bb081e")))
		 ;;  emacs-gptel))
		 )))
