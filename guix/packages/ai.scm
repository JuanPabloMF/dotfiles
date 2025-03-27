(define-module (packages ai)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (guix packages)
  #:use-module (guix git-download)
  #:use-module (guix build-system emacs)
  #:use-module (gnu packages node)
  #:use-module (guix build-system node)
  #:use-module (guix build-system copy)
  #:use-module (gnu packages golang)
  #:use-module (gnu packages emacs)
  #:use-module (gnu packages emacs-xyz)
  #:use-module (gnu packages curl)
  #:use-module (guix gexp)
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

(define-public emacs-gptel
  (package
    (name "emacs-gptel")
    (version "0.9.8")
    (source (origin
              (method git-fetch)
              (uri (git-reference
                    (url "https://github.com/karthink/gptel")
                    (commit (string-append "v" version))))
              (file-name (git-file-name name version))
              (sha256
               (base32
                "1wjzv39pcg6lcmlw6yc4fdfln2cnshzaa0dxgkniq9dfznf7hnmd"))))
    (build-system emacs-build-system)
    (arguments
     (list
      #:phases
      #~(modify-phases %standard-phases
          (add-after 'unpack 'use-appropriate-curl
            (lambda* (#:key inputs #:allow-other-keys)
              (substitute* "gptel-curl.el"
                (("\"curl\"")
                 (string-append "\""
                                (search-input-file inputs "/bin/curl")
                                "\"")))
              (emacs-substitute-variables "gptel.el"
                ("gptel-use-curl" 't)))))))
    (inputs (list curl))
    (propagated-inputs (list emacs-compat))
    (home-page "https://github.com/karthink/gptel")
    (synopsis "GPTel is a simple ChatGPT client for Emacs")
    (description
     "GPTel is a simple ChatGPT asynchronous client for Emacs with no external
dependencies.  It can interact with ChatGPT from any Emacs buffer with ChatGPT
responses encoded in Markdown or Org markup.  It supports conversations, not
just one-off queries and multiple independent sessions.  It requires an OpenAI
API key.")
    (license license:gpl3+)))

;; (define-public claude-code-cli
;;   (package
;;     (name "claude-code-cli")
;;     (version "0.1.0") ;; Replace with actual version
;;     (source
;;      (origin
;;        (method git-fetch)
;;        (uri (git-reference
;;              (url "https://github.com/anthropics/claude-code.git")
;;              (commit "555b6b5b8a5f06f1e8725a584e62fb6b7c8eece5")))
;;        (file-name (git-file-name name version))
;;        (sha256
;;         (base32 "0000000000000000000000000000000000000000000000")))) ;; Replace with actual hash
;;     (build-system node-build-system)
;;     (arguments
;;      '(#:phases
;;        (modify-phases %standard-phases
;;          (add-after 'install 'install-executable
;;            (lambda* (#:key outputs #:allow-other-keys)
;;              (let* ((out (assoc-ref outputs "out"))
;;                     (bin (string-append out "/bin")))
;;                (mkdir-p bin)
;;                (symlink (string-append out "/lib/node_modules/@anthropic-ai/claude-code/bin/run")
;;                         (string-append bin "/claude"))))))))
;;     (inputs
;;      (list node))
;;     (home-page "https://github.com/anthropics/claude-code")
;;     (synopsis "Claude Code CLI for Anthropic's Claude")
;;     (description "Command-line interface for using Claude to assist with coding tasks.")
;;     (license (license:non-copyleft "URL to license")))) ;; Replace with actual license

(define-public emacs-claude-code
  (package
    (name "emacs-claude-code")
    (version "0.1.0")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/stevemolitor/claude-code.el")
             (commit "main")))
       (sha256
        (base32 "1g9rvs5asy5lwnxlkkrpdxny1n22qiy76pw6a9c1avpb3w2n663s"))))
    (build-system copy-build-system)
    (arguments
     `(#:install-plan
       '(("." "share/emacs/site-lisp/"))))  ;; Copy the entire directory
    (propagated-inputs
     (list emacs-transient emacs-eat))
    (synopsis "Use Claude AI Code API from Emacs")
    (description "Provides functions for interacting with Claude AI Code API, 
     including code generation, explanation, and editing.")
    (home-page "https://github.com/stevemolitor/claude-code.el")
    (license license:expat)))
