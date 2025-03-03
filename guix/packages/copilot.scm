(define-module (packages copilot)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (guix packages)
  #:use-module (guix git-download)
  #:use-module (guix build-system emacs)
  #:use-module (gnu packages emacs)
  #:use-module (gnu packages emacs-xyz)
  )

(define-public emacs-copilot
  (package
    (name "emacs-copilot")
    (version "1.0")
    (source (origin
              (method git-fetch)
              (uri (git-reference
                    (url "https://github.com/copilot-emacs/copilot.el")
                    (commit "fd68d2e79e11939f5c2024671f67602bb2b34b4a")))
              (file-name (git-file-name name version))
              (sha256
               (base32
                "0dal7gdgqvg9c6i2dw87b3alhs4i0778w3a18hipgc1mlysk0zjw"))))
    (build-system emacs-build-system)
    (propagated-inputs
     (list emacs-dash
	   emacs-f
	   emacs-editorconfig))
    (home-page "https://github.com/copilot-emacs/copilot.el")
    (synopsis "A github copilot integration")
    (description "A github copilot integration")
    (license license:expat)))
