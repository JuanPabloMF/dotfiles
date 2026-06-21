# Agent-shell pipe — design

**Date:** 2026-06-11
**Status:** Approved, ready for implementation plan
**File touched:** `~/.emacs.d/emacs.org` (literate config; tangled output `~/.emacs` is generated)

## Purpose

Move "knowledge" between two `agent-shell` buffers — e.g. take output from a
Gemini session and stage it as input for a Claude session. Replace the existing
`my/deep-research` hack with a small, generic primitive that supports both
synchronous grab and background ask flows.

The pipe is mechanical: it moves bytes. It does not editorialize, summarize, or
auto-format beyond a single user-customizable wrapper hook.

## Scope

In scope:

- Grab last output (or selected region) from a source agent-shell buffer and
  stage it in a destination agent-shell or viewport buffer.
- Ask: send a query to an existing source agent buffer, wait for its
  `prompt-ready` second-fire, and stage the answer in the destination.
- Ask-fresh: same as ask, but spawn a fresh source buffer for the query using a
  configurable default agent config.
- Cancel in-flight ask/ask-fresh pipes.
- Buffer-local sticky source pairing on the destination, with `C-u` re-pick.
- Customizable wrapping via a single function-valued defcustom.

Out of scope:

- Streaming partial outputs from source to destination (we only act on
  completion).
- Multi-hop pipes (X → Y → Z chained).
- Automated tests (manual verification only — code calls live external agents).
- Replacing `agent-shell`'s existing context-source mechanism.

## Architecture

### Core primitive

```elisp
(my/agent-pipe--inject SOURCE-BUFFER DEST-BUFFER CONTENT &key QUERY SUBMIT)
```

The only function that actually moves bytes. Responsibilities:

1. If `my/agent-pipe-wrap-format` is non-nil, call it as
   `(funcall my/agent-pipe-wrap-format CONTENT SOURCE-NAME QUERY)` and use the
   result as the text to inject. `SOURCE-NAME` is `(buffer-name SOURCE-BUFFER)`;
   `QUERY` is nil in grab mode.
2. Dispatch on `DEST-BUFFER`'s major mode:
   - `agent-shell-mode` → `agent-shell--insert-to-shell-buffer` with
     `:shell-buffer DEST-BUFFER`, `:text WRAPPED`, `:submit SUBMIT`,
     `:no-focus t`.
   - `agent-shell-viewport-view-mode` or `agent-shell-viewport-edit-mode` →
     `agent-shell-viewport--show-buffer :append WRAPPED :shell-buffer
     (agent-shell-viewport--shell-buffer)`. (If `SUBMIT` is non-nil for a
     viewport destination, after staging we need to also submit — to be
     resolved in the plan; viewport's submission API needs inspection.)
   - Anything else → `user-error`.
3. Return nothing meaningful; side-effects only.

Everything user-facing is a thin wrapper around this.

### Source selection

Shared helper `my/agent-pipe--pick-source (DEST-BUFFER &optional REPROMPT)`:

1. If `REPROMPT` is non-nil → skip cache, go to step 4.
2. If `DEST-BUFFER`'s buffer-local `my/agent-pipe--sticky-source` is set and
   still live → return it.
3. Among `(agent-shell-buffers)` excluding `DEST-BUFFER`, if exactly one is
   live → return it (and cache as sticky).
4. Otherwise `completing-read` over live `(agent-shell-buffers)` excluding
   `DEST-BUFFER`. Cache the choice on `DEST-BUFFER`'s
   `my/agent-pipe--sticky-source`.
5. If no other live agent-shell buffers exist → `user-error`.

Cache invalidation is lazy: dead buffer checks happen at read time. No
buffer-kill hook.

### In-flight tracking

Top-level `my/agent-pipe--inflight` is a list of plists:

```
(:source BUF :dest BUF :query STR :subscription TOKEN
 :submit BOOL :fresh-spawn-p BOOL :initialized BOOL)
```

- Append on ask/ask-fresh start.
- `:initialized` toggles on first `prompt-ready` (interpreted as "source agent
  ready, send the query now").
- On second `prompt-ready`, extract via `shell-maker-last-output`, call
  `my/agent-pipe--inject`, unsubscribe, remove from list. If
  `:fresh-spawn-p` and `my/agent-pipe-kill-fresh-source-after`, kill the source.
- Per-destination guard: ask/ask-fresh signals `user-error` if any plist in
  `my/agent-pipe--inflight` already targets the current `DEST-BUFFER`.
- Different destinations may have pipes running concurrently.

### Source/destination death

The `prompt-ready` callback checks `(buffer-live-p ...)` for both source and
destination. If either is dead: unsubscribe (if source is dead, the
subscription is already moot), drop the plist, no error popup.

## User-facing commands

### `my/agent-pipe-grab`

- Destination: `(current-buffer)`. Must be `agent-shell-mode` or a viewport
  mode; else `user-error`.
- Source: `my/agent-pipe--pick-source` with `REPROMPT = (equal current-prefix-arg '(4))`.
- Content: if `(use-region-p)` in source buffer → region text; else
  `(with-current-buffer source (shell-maker-last-output))`.
- `SUBMIT`: `(equal current-prefix-arg '(16))` (i.e. `C-u C-u`).
- Calls `my/agent-pipe--inject` immediately. Synchronous.

### `my/agent-pipe-ask`

- Destination: current buffer (same constraint as grab).
- Source: same picker.
- Query: if `(use-region-p)` in destination buffer → region text; else
  `(read-string "Query for <source-name>: ")`.
- Per-destination concurrency check.
- Subscribe to `prompt-ready` on source; first fire sends the query via
  `agent-shell--insert-to-shell-buffer` (`:submit t`, `:no-focus t`); second
  fire extracts last output and injects into destination.
- `SUBMIT` propagated from `(equal current-prefix-arg '(16))`.

### `my/agent-pipe-ask-fresh`

- Destination: current buffer (same constraint).
- Source: spawn via `(agent-shell--start :config (funcall my/agent-pipe-default-config) :no-focus t :new-session t :session-strategy 'new)`.
- Query: same as ask.
- Per-destination concurrency check.
- Same two-phase `prompt-ready` flow as ask.
- After successful inject: if `my/agent-pipe-kill-fresh-source-after` is non-nil,
  kill the spawned source buffer.
- `SUBMIT`: same `C-u C-u` rule.
- With `C-u` (single prefix arg): prompt for which config builder to use,
  overriding `my/agent-pipe-default-config` for this invocation only. Choices
  come from a small interactive completion over
  `(agent-shell-google-make-gemini-config
    agent-shell-anthropic-make-claude-code-config ...)` — the exact list is a
  defvar `my/agent-pipe-config-builders`.

### `my/agent-pipe-cancel`

- With no prefix arg: find entries in `my/agent-pipe--inflight` whose `:dest`
  is `(current-buffer)`, unsubscribe each, drop from list.
- With `C-u`: cancel all in-flight pipes globally.
- For pipes spawned via ask-fresh: do not kill the source buffer (user can do
  that manually if they want it gone).
- If no matching pipes: `(message "No pipes to cancel.")`.

## Defcustoms

```elisp
(defcustom my/agent-pipe-wrap-format
  #'my/agent-pipe-default-wrap
  "Function called as (FN CONTENT SOURCE-NAME QUERY) to wrap piped content.
QUERY is nil in grab mode, the query string in ask/ask-fresh mode.
Return the wrapped string. Set to nil to paste raw without wrapping."
  :type '(choice (const :tag "Raw, no wrapping" nil)
                 (function :tag "Wrapping function")))

(defcustom my/agent-pipe-default-config
  #'agent-shell-google-make-gemini-config
  "Config builder used by `my/agent-pipe-ask-fresh' to spawn a source."
  :type 'function)

(defcustom my/agent-pipe-kill-fresh-source-after nil
  "If non-nil, kill the freshly spawned source buffer after extraction."
  :type 'boolean)
```

Default wrapper:

```elisp
(defun my/agent-pipe-default-wrap (content source-name query)
  (concat (format "<from %s>\n" source-name)
          (when query (format "Query: %s\n\n" query))
          content
          (format "\n</from %s>" source-name)))
```

## Keybindings

Prefix `C-c |`, defined on both `agent-shell-mode-map` and the two viewport
mode maps (`agent-shell-viewport-edit-mode-map`,
`agent-shell-viewport-view-mode-map`):

| Key       | Command                  |
|-----------|--------------------------|
| `C-c | g` | `my/agent-pipe-grab`     |
| `C-c | a` | `my/agent-pipe-ask`      |
| `C-c | f` | `my/agent-pipe-ask-fresh`|
| `C-c | c` | `my/agent-pipe-cancel`   |

`C-c C-r` (the old `my/deep-research` binding) is removed.

## Removals

The following are deleted from `emacs.org` (around lines 729–843 of the current
file):

- `my/deep-research--active` defvar
- `my/deep-research--on-complete`
- `my/deep-research`
- `my/deep-research-cancel`
- The three `(define-key ... (kbd "C-c C-r") #'my/deep-research)` lines

After implementation, the memory entry at
`~/.claude/projects/-home-juanpablo--emacs-d/memory/` describing the
"Deep Research Feature" should be updated to point at the new pipe primitive
(handled at implementation completion, not part of this spec).

## File placement in `emacs.org`

The new block goes inside the existing `(use-package agent-shell ... :config ...)` block,
replacing the deleted deep-research section. Same load timing, same access to
internal `agent-shell--start` / `agent-shell--insert-to-shell-buffer`.

A new subsection heading "Agent-shell pipe" should be added above the code
block.

## Testing approach

Manual only:

1. Open two agent-shell buffers (Claude in one, Gemini in another).
2. From Claude: `C-c | g` — grab Gemini's last output. Verify it lands in
   Claude's viewport/prompt wrapped by the default formatter (`<from
   *agent-shell-Gemini*>...</from ...>`).
3. From Claude, with a region selected in Gemini: `C-c | g`. Verify only the
   region moves.
4. From Claude: `C-c | a`, type a query. Verify it routes to Gemini, waits,
   then lands in Claude.
5. From Claude: `C-c | f`. Verify a fresh Gemini buffer spawns, query goes,
   answer lands.
6. `C-u C-c | g` — verify re-prompt for source.
7. `C-u C-u C-c | g` — verify auto-submit fires.
8. Two destinations with concurrent ask pipes — verify both complete and don't
   stomp on each other.
9. Kill source mid-pipe — verify no error popup.
10. `C-c | c` — verify cancel cleans up subscription and `my/agent-pipe--inflight`.

## Open questions for the plan

- **Viewport submission with `:submit t`**: viewport modes stage text, they
  don't submit it. The plan needs to verify whether
  `agent-shell-viewport--show-buffer` has a submit-after-append option, or
  whether we need a follow-up call (e.g. simulate `C-c C-c`) to fire
  submission. If no clean path exists, scope `:submit t` to apply only when the
  destination is `agent-shell-mode`, and document the limitation.
- **Config builder enumeration for `ask-fresh` with `C-u`**: the spec lists a
  defvar `my/agent-pipe-config-builders` but the actual list of available
  builders depends on which `agent-shell-*.el` files have been loaded. The plan
  should decide: hardcode a known-good list, or derive dynamically via
  `apropos`?
