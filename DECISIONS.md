# VReader Decisions

## 2026-05-25 — Markdown state is primary, Skaro is secondary

Context:
Skaro task/status memory became unreliable or was not visible after migration. However `.skaro/constitution.md`, usage logs, Claude rules and code changes survived.

Decision:
Use normal markdown files under Git as the primary source of project state:

- PROJECT_STATE.md
- TASKS.md
- DECISIONS.md
- RECOVERY_LOG.md
- AI_NOTES.md

Skaro may remain installed and usable, but it must not be the only place where project memory lives.

Consequences:
- Every meaningful architecture decision must update DECISIONS.md.
- Every significant AI-assisted change must update AI_NOTES.md.
- Tasks must be reflected in TASKS.md.
- Skaro state can be regenerated or ignored if it becomes inconsistent.

## 2026-05-25 — Active codebase is App/Vreader/Vreader

Context:
The constitution marks `App/Vreader/Vreader/` as the active codebase and `Vreader/` as legacy.

Decision:
All new changes should target:

```text
App/Vreader/Vreader/
```

Do not modify:

```text
Vreader/
```

unless explicitly requested.

## 2026-05-25 — Do not commit secrets or local credentials

Decision:
Do not read or commit:

- `.env`
- `.env.*`
- secrets
- certificates
- provisioning profiles
- SSH keys
- local credentials

Keychain remains the only storage for app secrets.
