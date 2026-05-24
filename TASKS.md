# VReader Tasks

Status legend:

- `[done]` completed or mostly implemented
- `[active]` current work
- `[todo]` not started
- `[verify]` needs build/test/manual verification
- `[unknown]` recovered from logs, status uncertain

## Recovered from Skaro usage log

### project-structure-cleanup

Status: `[verify]`

Evidence:
- Skaro usage log contains clarify / plan / implement phases.
- Constitution says active codebase is `App/Vreader/Vreader/`.
- Legacy `Vreader/` should not be used for new changes.

Next checks:
- Verify no new changes were made in legacy `Vreader/`.
- Run `Description/check_refs.py`.
- Check Xcode target references.

### design-tokens

Status: `[verify]`

Evidence:
- Skaro usage log contains clarify / plan / implement / fix phases.
- Constitution references ThemeStore, AppThemeKey and premium themes.

Next checks:
- Inspect theme-related files.
- Verify theme selection works.
- Verify premium themes remain gated.

### app-theme-system

Status: `[verify]`

Evidence:
- Skaro usage log contains clarify / plan / implement phases.
- Constitution says theme changes must go through `ThemeStore.setTheme(_:isPremiumUser:)`.

Next checks:
- Inspect ThemeStore implementation.
- Verify `isPremium` is not synced through CloudKit.
- Verify UI uses environment theme.

### import_analyze

Status: `[unknown]`

Evidence:
- Skaro usage log contains import_analyze on 2026-05-19.
- No detailed task state recovered yet.

Next checks:
- Inspect changed import/reader files.
- Check `ReaderView.swift`, `AudioPlayerView.swift`, `L10n.swift`.
- Determine what import analysis produced.

## Current active recovery tasks

### Recover project state

Status: `[active]`

Tasks:
- Create PROJECT_STATE.md.
- Create TASKS.md.
- Create DECISIONS.md.
- Create RECOVERY_LOG.md.
- Create AI_NOTES.md.
- Commit recovery branch.

### Stabilize diagnostics/network layer

Status: `[verify]`

Files:
- `App/Vreader/Vreader/DiagnosticsService.swift`
- `App/Vreader/Vreader/NetworkMonitor.swift`

Tasks:
- Inspect implementation.
- Check compile errors.
- Ensure no secrets or network credentials are logged.
- Add localization if user-facing strings exist.

### Verify modified reader/audio files

Status: `[verify]`

Files:
- `AudioPlayerView.swift`
- `ReaderView.swift`
- `L10n.swift`

Tasks:
- Inspect changes.
- Run build.
- Run `Description/check_refs.py`.
- Confirm user-facing strings use `L10n.*`.

## Backlog

### Build verification

Status: `[todo]`

Command candidates:
- `xcodebuild -list`
- targeted Xcode build
- `python3 Description/check_refs.py`

### Replace Skaro as source of truth

Status: `[active]`

Decision:
- Keep Skaro as optional assistant layer.
- Use Markdown + Git as primary state.
