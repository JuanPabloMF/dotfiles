# Emacs Configuration Overview

Literate config in `emacs.org`, tangled to `~/.emacs`.

## Package Management

Three-layer system:

- **GNU Guix** (primary) -- most packages installed via `guix home` profile at `~/.guix-home/profile`. `use-package-always-ensure` is `nil`.
- **straight.el** -- for packages not in Guix (GitHub-only repos like agent-shell, winpulse, claude-code-ide).
- **MELPA** -- available as a fallback archive.

Local elisp goes in `site-lisp/` (auto-added to `load-path` with subdirs).

## Startup Performance

- `gc-cons-threshold` set to `most-positive-fixnum` during init, then 100MB after startup.
- `read-process-output-max` set to 1MB for LSP/subprocess throughput.
- Heavy packages use `:defer t` / `:commands` to avoid loading until needed.

## UI

| Feature | Package |
|---|---|
| Theme | `doom-palenight` via `doom-themes` |
| Modeline | `doom-modeline` (height 15) |
| Icons | `all-the-icons` |
| File hygiene | `no-littering` (config/ and data/ subdirs) |
| Window pulse | `winpulse` |

Minimal chrome: no scroll bar, toolbar, tooltip, or menu bar. Line numbers on globally. Frame transparency at 95%.

## Keybindings

Uses `general.el` with a custom `my/general-define-key` macro for grouped definitions. Emacs-native bindings (no Evil).

### Global

| Key | Action |
|---|---|
| `M-w` | `easy-kill` |
| `C-@` | `er/expand-region` |
| `C-s` | `swiper-isearch` (DWIM: respects region, multiple-cursors, kbd macros) |
| `M-s` | `swiper` |
| `C-M-s` | `avy-goto-char` |
| `M-o` | `ace-window` |
| `C-x C-b` | `counsel-switch-buffer` |
| `M-/` | `evilnc-comment-or-uncomment-lines` |

### AI / Tools

| Key | Action |
|---|---|
| `C-c a` | `agent-shell` |
| `C-c c` | `claude-code-ide-menu` |
| `C-c g` | `gptel-menu` |
| `C-c e` | `elfeed` |

### Snippets (`C-c s` prefix)

| Key | Action |
|---|---|
| `C-c s w` | `aya-create` |
| `C-c s y` | `aya-expand` |
| `C-c s l` | `ivy-yasnippet` |
| `C-c s s` | `aya-persist-snippet` |

### Multiple Cursors

| Key | Action |
|---|---|
| `C->` | `mc/mark-next-like-this` |
| `C-<` | `mc/mark-previous-like-this` |
| `C-c C->` | `mc/mark-all-like-this` |
| `C-S-c C-S-c` | `mc/edit-lines` |

### Eglot / LSP (`C-c l u` prefix)

| Key | Action |
|---|---|
| `C-c l u r` | `xref-find-references` |
| `C-c l u d` | `xref-find-definitions` |
| `C-c l u g` | `eldoc` |
| `C-c l u m` | `imenu` |
| `C-c l u a` | `eglot-code-actions` |
| `C-c l u n` | `eglot-rename` |
| `C-c l u f` | `eglot-format` |

### Python Navigation

| Key | Action |
|---|---|
| `C-M-b / C-M-f` | Navigate blocks |
| `C-M-a / C-M-e` | Navigate defuns |
| `C-M-u` | Up list |

### Jupyter / Code Cells (`C-c j` prefix)

| Key | Action |
|---|---|
| `C-c j e` | Eval cell |
| `C-c j b / f` | Navigate cells |
| `C-c j B / F` | Move cells up/down |
| `C-c j ;` | Comment/uncomment cell |
| `C-c j @` | Mark cell |
| `C-c j r` | `jupyter-eval-region` |

## Discoverability

- **which-key** -- shows available bindings after 1s delay.
- **Ivy + Counsel** -- completion framework for buffers, files, M-x, etc.
- **ivy-rich** -- adds metadata columns to Ivy candidates.
- **counsel-tramp** -- TRAMP host completion.

## Editing

| Package | Purpose |
|---|---|
| `avy` | Jump to visible text by character |
| `ace-window` | Window switching with labels |
| `expand-region` | Semantic selection expansion |
| `easy-kill` | Enhanced M-w (kill-ring-save) |
| `phi-search` | Isearch compatible with multiple-cursors |
| `multiple-cursors` | Multi-cursor editing |
| `ediff` | Configured for plain horizontal split |

Buffer switching skips `*special*` buffers (except `*scratch*`).

## LSP (Eglot)

Built-in Eglot (Emacs 29+) with:

- Auto-start on `python-mode` via `eglot-ensure`.
- Flex completion style for LSP completions.
- `jsonrpc` event logging suppressed for performance.
- Syntax checking via **Flymake** (built-in), activated in eglot-managed buffers.
- `miniconda3/bin` on `exec-path` for language servers.

## Python Development

- **python-mode** -- interpreter set to Guix profile python3, 4-space indent.
- **pyvenv** -- virtualenv activation/switching.
- **jupyter** -- REPL connection and region evaluation.
- **drepl** -- IPython REPL integration.
- **code-cells** -- notebook-style cell editing in `.py` files (with `# %%` markers), auto-converts `.ipynb`.

## Remote Development (TRAMP)

- `tramp-container` for Docker/Podman access (replaced `docker-tramp`).
- Custom `sshxa` method: SSH with agent forwarding (`-A`) and remote command support.

## Project Management

Built-in `project.el` with custom additions:

- `project-shell` (`C-x p s`) -- shell at project root.
- `project-dired` (`C-x p d`) -- dired at project root.
- `~/work/orgfiles/` registered as a known project.

## Org Mode

- `org-indent-mode` and `visual-line-mode` enabled.
- Babel languages: emacs-lisp, python, shell (no confirmation prompt).
- Source blocks preserve indentation at column 0.
- **org-bullets** for prettier headings.
- **org-download** for drag-and-drop images.
- **org-tree-slide** for presentations (with `hide-lines` to clean source blocks).
- **ox-hugo** for Hugo blog export.

## AI Integration

### gptel

Multi-backend LLM chat (default: Claude Sonnet 4.6 via Anthropic API):

- Backends: Anthropic Claude, Google Gemini.
- Tool use enabled (includes a `read_url` tool for web fetching).
- Media tracking on.
- Custom transient suffix `j` to jump between gptel chat buffers.
- API keys read from `~/.authinfo` via `auth-source`.

### agent-shell

Claude Code agent inside Emacs:

- Anthropic authentication with environment inheritance.
- Dired integration: marked files sent as context.
- Pop-up window display.

### agent-shell-to-go

Slack bot bridge for agent-shell. Tokens managed via 1Password CLI.

### claude-code-ide

Claude Code terminal (via `eat` backend) accessible at `C-c c`.

### Other

- **acp.el** -- Anthropic completion provider.
- **smerge-mode** -- merge conflict resolution, active in all prog-mode buffers.

## Templates

- **yasnippet** -- snippet expansion in prog-mode and shell-mode. Snippets in `~/.emacs.d/snippets/`.
- **auto-yasnippet** -- on-the-fly snippet creation (`aya-create` / `aya-expand`).
- **ivy-yasnippet** -- browse and insert snippets via Ivy.

## Git

**Magit** for Git operations (deferred loading).

## Other

- **restclient** -- HTTP client for `.http` files.
- **elfeed** -- RSS reader (subscribed to Planet Emacslife).
- **eat** -- terminal emulator.

## Custom Elisp Utilities

| Function | Purpose |
|---|---|
| `f-string` | Python-style f-string interpolation macro |
| `my/load-default-init-file` | Reload `~/.emacs` |
| `my/stop-emacs-server` | Kill emacs daemon process |
| `my/swiper-isearch-dwim` | Context-aware search (region, multiple-cursors, macros) |
| `my/jump-to-register-end-of-line` | Jump to register + move to EOL |
| `csetq` | `customize`-aware `setq` macro |
