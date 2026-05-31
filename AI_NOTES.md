# AI Notes

## 2026-05-25 — Project state recovery

Reason:
Skaro task/status memory was not reliable after migration. Local `.skaro`, `.claude`, `CLAUDE.md` and code changes were still present.

Action:
Created markdown project state files to make project memory durable and Git-trackable.

Files:
- PROJECT_STATE.md
- TASKS.md
- DECISIONS.md
- RECOVERY_LOG.md
- AI_NOTES.md

Policy:
Markdown + Git is now the primary source of project state.
Skaro is optional and secondary.
