# Claude Code Project Rules

Project: VReader
Type: iOS/macOS Application
Stack: Swift, SwiftUI, Xcode

---

# Core Workflow

* Use ultra-low-token workflow.
* Make small atomic changes.
* Prefer minimal diffs.
* Do not refactor unless explicitly requested.
* Never scan the full repository unless explicitly asked.
* Read only files required for the current task.
* Avoid repeated file reads.
* Keep outputs concise.
* Show no diffs unless explicitly requested.
* After edits, reply only:

  * "Done"
  * or "Updated X files"

---

# Architecture Discipline

* Prefer architecture-first reasoning.
* Prefer stable and maintainable solutions.
* Avoid speculative abstractions.
* Avoid premature optimization.
* Avoid overengineering.
* Preserve existing project structure and naming conventions.

---

# Editing Rules

* Touch only files relevant to the task.
* Avoid unrelated formatting changes.
* Avoid broad rewrites.
* Preserve compatibility with current architecture.
* When unsure about architecture changes — ask first.

---

# Token Economy Rules

* Never dump full Xcode logs.
* Never dump full build output.
* Never dump huge git diffs.
* Summarize errors briefly.
* Prefer focused debugging.
* Prefer targeted search over broad exploration.
* Avoid unnecessary context expansion.

---

# Build / Debug Workflow

Preferred:

* focused debugging
* incremental fixes
* minimal edits
* concise summaries

Avoid:

* repo-wide scans
* mass rewrites
* broad refactors
* giant console outputs

---

# Safety

* Never read:

  * .env
  * .env.*
  * secrets
  * certificates
  * provisioning profiles
  * SSH keys
  * local credentials

* Never log API keys or tokens.

* Never run destructive commands without explicit approval.

* Never force-push unless explicitly requested.

---

# Git Rules

* Keep VReader and GEO as separate repositories.
* Do not modify remotes unless explicitly requested.
* Before broad changes, check git status.
* Prefer small focused commits.

---

# Compacting Rules

When compacting context, preserve only:

* Goal
* Changed files
* Decisions
* Current failure
* Verification
* Next step

---

# RTK Rules

Use RTK-prefixed commands whenever possible.

Preferred commands:

* rtk git status
* rtk git diff
* rtk grep
* rtk read
* rtk ls
* rtk find
* rtk log
* rtk npm
* rtk pnpm
* rtk swift build
* rtk xcodebuild

Rules:

* Prefer compact outputs.
* Avoid raw logs unless explicitly requested.
* Avoid large diffs.
* Prefer summaries over full outputs.
* Use RTK automatically for noisy commands.

Meta:

* rtk gain
* rtk discover
* rtk proxy

---

# Communication Style

* Be concise.
* Be implementation-focused.
* Prefer practical solutions over theoretical discussion.
* Avoid unnecessary explanations.

---

# Skaro Project Memory

Project planning and architecture memory lives in `.skaro/`.

Important sources:
- `.skaro/config.yaml`
- `.skaro/state.yaml`
- `.skaro/devplan.md`
- `.skaro/architecture/`
- `.skaro/milestones/`
- `.skaro/invariants.md`

Use `.skaro/` only when the task requires:
- architecture decisions
- milestone planning
- system design
- dependency reasoning
- implementation roadmap context

Do not scan the entire `.skaro/` directory unless explicitly requested.
Prefer targeted reads only.
