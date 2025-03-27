(define-module (packages ensure-guix)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (guix packages)
  #:use-module (guix git-download)
  #:use-module (guix build-system emacs)
  #:use-module (gnu packages emacs)
  #:use-module (gnu packages emacs-xyz))

(define-public emacs-use-package-ensure-guix
  (package
    (name "emacs-use-package-ensure-guix")
    (version "0.1.0")
    (source (origin
              (method git-fetch)
              (uri (git-reference
                    (url "https://github.com/paperclip4465/use-package-ensure-guix")
                    (commit "beb14b24964e21c9991d7674924ed19ffb049aca")))
              (file-name (git-file-name name version))
              (sha256
               (base32
                "04fsb4hwhp8kixlxj24bq14fkcsrndivvdv2s9v1ivjga6c6zxlx"))))
    (build-system emacs-build-system)
    (propagated-inputs
     (list emacs-use-package
	   emacs-guix))
    (home-page "https://github.com/abcdw/use-package-ensure-guix")
    (synopsis "Guix integration for use-package")
    (description "This package provides a :ensure-guix keyword for use-package
which allows you to install packages via Guix directly from within Emacs.")
    (license license:gpl3+)))
