# VReader Project State

Last recovered: 2026-05-25

## Project

VReader is a Swift / SwiftUI / SwiftData reading application for iOS, macOS and visionOS.

Active codebase:

```text
App/Vreader/Vreader/
```

Legacy directory:

```text
Vreader/
```

Do not modify the legacy directory unless explicitly requested.

## Current stack

- Swift 5.0
- SwiftUI
- SwiftData
- PDFKit
- AVFoundation
- WebKit
- ZIPFoundation 0.9.20
- iCloud documents + NSUbiquitousKeyValueStore
- KeychainManager actor for secrets
- UserDefaults for reader settings

## Important architecture rules

- Book model in active App version uses `coverPath: String?`.
- Legacy `coverData: Data?` should not be reintroduced.
- User-facing strings should go through `L10n.*`.
- Theme changes should go through `ThemeStore.setTheme(_:isPremiumUser:)`.
- Premium theme entitlement should not be synced through CloudKit.
- OAuth is not implemented yet; if added, use ASWebAuthenticationSession.
- WKWebView is forbidden for OAuth.
- Keychain is the only storage for passwords, tokens and API keys.
- Do not read `.env`, secrets, certificates, provisioning profiles, SSH keys.
- Do not read DerivedData, build, .build, Pods.

## Current recovery evidence

Recovered from local project state:

- `.skaro/constitution.md`
- `.skaro/token_usage.yaml`
- `.skaro/usage_log.jsonl`
- `CLAUDE.md`
- `.claude/settings.json`
- `.claude/hooks/*`
- changed Swift files
- new `DiagnosticsService.swift`
- new `NetworkMonitor.swift`

## Current modified files at recovery

```text
.claude/hooks/block-danger.sh
.claude/hooks/format-touched.sh
.claude/hooks/log-command.sh
.claude/settings.json
.gitignore
.skaro/constitution.md
.skaro/token_usage.yaml
.skaro/usage_log.jsonl
App/Vreader/Vreader/AudioPlayerView.swift
App/Vreader/Vreader/L10n.swift
App/Vreader/Vreader/ReaderView.swift
CLAUDE.md
Description/check_refs.py
App/Vreader/Vreader/DiagnosticsService.swift
App/Vreader/Vreader/NetworkMonitor.swift
```

## Current policy

- Markdown state files are the primary source of truth.
- Skaro is secondary.
- Claude rules are kept in `CLAUDE.md` and `.claude/`.
- Every meaningful architecture decision should update `DECISIONS.md` and `AI_NOTES.md`.
