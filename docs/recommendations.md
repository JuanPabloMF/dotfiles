# Workflow Recommendations

Suggestions for a Python / data science / CTO workflow, based on what's already in the config and what's missing.

## High Priority

### 1. Add corfu + cape for in-buffer completion

The config has an "In-buffer Completion" section that's empty. Eglot feeds `completion-at-point`, but without a completion UI you only get the default `*Completions*` buffer. `corfu` provides a fast, minimal popup.

```elisp
(use-package corfu
  :custom
  (corfu-auto t)
  (corfu-auto-delay 0.2)
  (corfu-cycle t)
  :init
  (global-corfu-mode))

(use-package cape
  :init
  (add-hook 'completion-at-point-functions #'cape-dabbrev)
  (add-hook 'completion-at-point-functions #'cape-file))
```

Both are available in Guix (`emacs-corfu`, `emacs-cape`).

### 2. Add ruff or ruff-lsp for Python linting/formatting

Ruff is an extremely fast Python linter and formatter that replaces flake8, isort, black, and pyflakes. Eglot can use `ruff-lsp` or `ruff server` (built-in as of ruff 0.4+) as an additional language server.

```elisp
;; If using ruff's built-in server (ruff >= 0.4):
(with-eval-after-load 'eglot
  (add-to-list 'eglot-server-programs
               '(python-mode . ("ruff" "server"))))

;; Or run both pyright + ruff:
;; (add-to-list 'eglot-server-programs
;;              '(python-mode . ("pyright-langserver" "--stdio")))
;; and use eglot-format to call ruff for formatting.
```

Install: `pip install ruff` or `guix install ruff`.

### 3. Add treesit for better syntax highlighting and navigation

Emacs 29+ ships with tree-sitter support. `python-ts-mode` gives much better syntax highlighting and structural navigation than the regex-based `python-mode`.

```elisp
(use-package python
  :ensure nil
  :mode ("\\.py\\'" . python-ts-mode)
  :interpreter ("python" . python-ts-mode)
  :config
  (setq python-shell-interpreter "/home/juanpablo/.guix-home/profile/bin/python3"))
```

Requires tree-sitter grammars installed. Check `treesit-language-available-p`.

### 4. Add envrc or direnv integration

As CTO you likely jump between many projects with different Python versions, virtualenvs, and environment variables. `envrc` (or `inheritenv`) automatically activates `.envrc` per-project, so eglot picks up the right Python and packages.

```elisp
(use-package envrc
  :init
  (envrc-global-mode))
```

This replaces the manual `pyvenv-activate` workflow and plays well with both conda and virtualenvs.

### 5. Set up org-agenda for task management

The config has `org-capture` and `org-agenda` as commands but no capture templates or agenda files. As CTO, a lightweight task/meeting system in org is very powerful.

```elisp
(setq org-agenda-files '("~/work/orgfiles/"))
(setq org-capture-templates
      '(("t" "Task" entry (file "~/work/orgfiles/tasks.org")
         "* TODO %?\n  %U\n  %a")
        ("m" "Meeting note" entry (file "~/work/orgfiles/meetings.org")
         "* %? :meeting:\n  %U\n  %^{Attendees}p")))
```

## Medium Priority

### 6. Add consult for enhanced search/navigation

`consult` provides richer alternatives to several built-in commands that integrate well with your Ivy setup (or as a migration path to vertico later):

- `consult-ripgrep` -- project-wide grep (much faster than counsel-rg).
- `consult-imenu` -- jump to symbols across buffers.
- `consult-flymake` -- navigate diagnostics.
- `consult-line` -- swiper alternative with preview.

### 7. Add dape for debugging

`dape` is a built-in-friendly Debug Adapter Protocol client (Emacs 29+). Works with `debugpy` for Python.

```elisp
(use-package dape
  :config
  (add-to-list 'dape-configs
               '(debugpy
                 modes (python-mode python-ts-mode)
                 command "python"
                 command-args ("-m" "debugpy.adapter")
                 :type "executable"
                 :request "launch"
                 :program dape-buffer-default)))
```

Replaces the need for `dap-mode` (which depends on `lsp-mode`).

### 8. Add docker / kubernetes integration

For a CTO managing infrastructure, `docker.el` and `kubel` provide interactive management from Emacs. The TRAMP container support is already set up, so you can edit files inside running containers via `/docker:container:/path`.

### 9. Add csv-mode and rainbow-csv

Data science work often involves CSV inspection. `csv-mode` provides alignment and field navigation; `rainbow-csv` colors columns for readability.

### 10. Add markdown-mode

For README files, documentation, and GitHub PR descriptions. Currently missing from the config.

```elisp
(use-package markdown-mode
  :mode ("\\.md\\'" . markdown-mode))
```

### 11. Improve gptel with org-mode integration

gptel supports sending org subtrees as context. Consider adding:

```elisp
(setq gptel-default-mode 'org-mode)
```

This makes new gptel buffers use org-mode, so responses are formatted with headings and code blocks.

## Nice to Have

### 12. Add project-specific eglot config

For multi-repo work, `.dir-locals.el` per project can configure eglot server args:

```elisp
;; In project .dir-locals.el:
((python-mode . ((eglot-workspace-configuration
                  . (:python (:analysis (:typeCheckingMode "strict")))))))
```

### 13. Consider switching from Ivy to Vertico + Orderless

The Emacs ecosystem is moving toward vertico + orderless + marginalia + consult as the modern completion stack. It's lighter, more composable, and uses built-in Emacs completion APIs. Not urgent since Ivy works, but worth considering for the long term.

### 14. Add a Jupyter notebook viewer

Beyond `code-cells`, consider `ein` (Emacs IPython Notebook) for full notebook rendering inside Emacs, or use `jupytext` to auto-sync `.ipynb` to `.py` files.

### 15. Add pdf-tools for reading papers

Useful for data science research. `pdf-tools` provides a much better PDF viewer than DocView.

```elisp
(use-package pdf-tools
  :mode ("\\.pdf\\'" . pdf-view-mode)
  :config
  (pdf-tools-install))
```

### 16. Add which-func-mode

Shows the current function name in the modeline. Helpful when navigating large Python files.

```elisp
(which-function-mode 1)
```

### 17. Add savehist and recentf

The "Ideas" section mentions "save history". These two built-in packages handle it:

```elisp
(savehist-mode 1)  ;; persist minibuffer history across sessions

(recentf-mode 1)   ;; track recently opened files
(setq recentf-max-saved-items 200)
```

`counsel-recentf` already works with Ivy for file access.
