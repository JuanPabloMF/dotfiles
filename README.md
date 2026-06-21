# Emacs Configuration

Literate Emacs configuration using `org-babel`. The main config lives in [`emacs.org`](emacs.org) and tangles to `~/.emacs`.

## Setup

**Requirements**: GNU Guix (home profile), `straight.el` (bootstrapped automatically).

```bash
git clone <this-repo> ~/.emacs.d
```

On first launch, Emacs will bootstrap `straight.el` and install packages from GitHub. Guix-managed packages are loaded from `~/.guix-home/profile/share/emacs/site-lisp/`.

### Package Management

- **Guix**: Primary source for stable packages (`use-package-always-ensure` is `nil`)
- **straight.el**: For packages not in Guix or that need bleeding-edge versions (agent-shell, claude-code-ide, etc.)
- **MELPA**: Available as fallback via `package.el`

## Structure

| Section | What it covers |
|---|---|
| **Bootstrapping** | GC tuning, Guix profile, straight.el, load-path |
| **UI** | doom-themes (palenight), doom-modeline, all-the-icons, no-littering |
| **Lisp** | Custom macros (`f-string`, `csetq`), utility functions |
| **Keybindings** | `general.el` bindings, which-key, multi-cursor, eglot/LSP keys |
| **Discoverability** | Ivy, counsel, ivy-rich, counsel-tramp |
| **Editing** | avy, ace-window, expand-region, easy-kill, multiple-cursors, ediff |
| **Tramp** | SSH with auth forwarding (`sshxa` method), tramp-container |
| **Org** | Babel (elisp, python, shell), org-bullets, org-download |
| **IDE** | eglot, yasnippet, flymake, python, jupyter, code-cells, pyvenv |
| **AI / Agents** | gptel, agent-shell, claude-code-ide, deep research (see below) |
| **Writing** | org-tree-slide (presentations), ox-hugo |
| **Great Packages** | magit, restclient, elfeed |

## AI / Agent Shell

The config uses [agent-shell](https://github.com/xenodium/agent-shell) as the primary AI interface, with Claude Code as the default agent.

### Keybindings

| Key | Command | Context |
|---|---|---|
| `C-c a` | `agent-shell` | Global |
| `C-c c` | `claude-code-ide-menu` | Global |
| `C-c g` | `gptel-menu` | Global |
| `C-c C-r` | `my/deep-research` | agent-shell / viewport |

### Agent Shell Config

```elisp
;; Claude Code as default agent
(setq agent-shell-preferred-agent-config
      (agent-shell-anthropic-make-claude-code-config))

;; Environment inherits from shell
(setq agent-shell-anthropic-claude-environment
      (agent-shell-make-environment-variables :inherit-env t))

;; Login-based authentication
(setq agent-shell-anthropic-authentication
      (agent-shell-anthropic-make-authentication :login t))
```

### Slack Integration

[agent-shell-to-go](https://github.com/ElleNajt/agent-shell-to-go) mirrors agent-shell conversations to Slack via WebSocket. Secrets are pulled from 1Password at load time.

## Deep Research (Gemini from Claude Code)

Run background research with Gemini CLI from within a Claude Code agent-shell session. Results are injected into the Claude Code viewport for review before sending.

### Usage

1. Open a Claude Code agent-shell (`C-c a`)
2. Press `C-c C-r` and enter a research query (or select a region first)
3. A Gemini CLI shell starts in the background — you keep working in Claude Code
4. When Gemini finishes, the viewport opens with the research results appended
5. Review/edit the results, then send to Claude Code with `C-c C-c`

With prefix `C-u C-c C-r`, the Gemini buffer is automatically killed after extracting results.

To cancel an in-progress research: `M-x my/deep-research-cancel`

### How It Works

```
C-c C-r → prompt for query
  → agent-shell--start Gemini CLI (:no-focus t, background)
  → subscribe to prompt-ready events on Gemini buffer
  → 1st prompt-ready: Gemini initialized → send query
  → (user continues working in Claude Code)
  → 2nd prompt-ready: Gemini done → extract via shell-maker-last-output
  → inject into Claude Code viewport via agent-shell-viewport--show-buffer :append
  → user reviews and sends with C-c C-c
```

### Key API Used

| Function | Purpose |
|---|---|
| `agent-shell--start` | Start Gemini shell with `:no-focus t` |
| `agent-shell-subscribe-to` | Listen for `prompt-ready` events |
| `agent-shell-unsubscribe` | Clean up subscriptions |
| `agent-shell--insert-to-shell-buffer` | Send query to Gemini without stealing focus |
| `agent-shell-viewport--show-buffer` | Append results to Claude Code viewport |
| `shell-maker-last-output` | Extract Gemini's response from comint buffer |

## Notable Custom Functions

| Function | Description |
|---|---|
| `f-string` | Python-like string interpolation macro |
| `my/swiper-isearch-dwim` | Context-aware search (multiple-cursors, phi-search, or swiper) |
| `my/deep-research` | Background Gemini research from Claude Code |
| `my/agent-shell-dired-marked-only` | Context source for dired marked files |
| `my/hide-headers` / `my/show-headers` | Toggle source block markers for presentations |

## Keybinding Philosophy

Emacs-native keybindings (no evil-mode). Uses `general.el` for consistent definitions and `which-key` for discoverability (1s idle delay).

### Quick Reference

| Key | Action |
|---|---|
| `C-s` | Smart search (swiper/phi-search depending on context) |
| `M-s` | Swiper (full line search) |
| `C-M-s` | avy-goto-char |
| `M-o` | ace-window |
| `C-@` | expand-region |
| `M-w` | easy-kill |
| `C->` / `C-<` | multiple-cursors next/prev |
| `M-/` | Comment/uncomment (evil-nerd-commenter) |
| `C-c l u r/d/g/a/n/f` | LSP: references/definitions/docs/actions/rename/format |
| `C-c j e/b/f` | Jupyter: eval cell / prev / next |
