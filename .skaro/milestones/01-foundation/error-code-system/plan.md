## Анализ задачи

Задача разбивается по естественной границе зависимостей:
- **Сначала** — типы (`ErrorCode`, `AppError`) + все локализованные строки (`L10n`, `.strings`). Без этого нельзя мигрировать существующие `throw`.
- **Затем** — обновление 5 файлов с `throw` (WebDAV, iCloud, BookImporter, Keychain, Diagnostics) с использованием типов и строк из Stage 1.

---

## Stage 1: Система типов ошибок — ErrorCode, AppError, L10n, Localizable.strings

**Goal:**
Полностью переписать `ErrorCode.swift` (расширенный набор кейсов, `Sendable`),
обновить `AppError.swift` (добавить `underlyingDescription: String?`, исправить
`Codable`, убрать все TODO-хардкоды строк, подключить `L10n.Errors.*`),
добавить `enum Errors` в `L10n.swift` со всеми строками ошибок,
добавить соответствующие `error.*`-ключи в оба `Localizable.strings`.

**Depends on:** нет

**Inputs:**
- `App/Vreader/Vreader/AppError.swift`
- `App/Vreader/Vreader/ErrorCode.swift`
- `App/Vreader/Vreader/L10n.swift`
- `App/Vreader/Vreader/en.lproj/Localizable.strings`
- `App/Vreader/Vreader/ru.lproj/Localizable.strings`
- Specification: error-code-system, Clarifications Q1–Q6
- Architecture, Constitution

**Outputs:**
- `App/Vreader/Vreader/ErrorCode.swift` *(переписан)*
- `App/Vreader/Vreader/AppError.swift` *(обновлён)*
- `App/Vreader/Vreader/L10n.swift` *(добавлен `enum Errors`)*
- `App/Vreader/Vreader/en.lproj/Localizable.strings` *(добавлены `error.*` ключи)*
- `App/Vreader/Vreader/ru.lproj/Localizable.strings` *(добавлены `error.*` ключи)*

**DoD:**
- [ ] `ErrorCode` — 8 категорий, каждая реализует `Equatable`, `Hashable`, `Codable`, `Sendable`, `CaseIterable` где применимо
- [ ] Все вложенные enum содержат расширенный практический набор кейсов из спецификации (FR-14): `FileSystemError` — 13 кейсов, `NetworkError` — 13, `CloudProviderError` — 13, `AIServiceError` — 11, `StoreKitError` — 9, `SyncError` — 9, `ParsingError` — 9, `AuthError` — 10
- [ ] `ErrorCode` реализует `Equatable`, `Hashable`, `Sendable`, `Codable` через ручной `encode/decode` (category + value)
- [ ] `AppError` содержит поля: `code: ErrorCode`, `description: String`, `recoveryHint: String`, `underlyingError: (any Error & Sendable)?`, `underlyingDescription: String?`
- [ ] `AppError` реализует `Error`, `LocalizedError`, `Sendable`, `Codable`
- [ ] `AppError.Codable` сериализует ровно 4 поля: `code`, `description`, `recoveryHint`, `underlyingDescription`; поле `underlyingError` явно исключено из `CodingKeys`
- [ ] `AppError.analyticsCode` возвращает строку вида `"category.case"` — без PII, путей, токенов, параметров (FR-11, NFR-04, NFR-05)
- [ ] `AppError.errorDescription` возвращает `description`, `recoverySuggestion` возвращает `recoveryHint` (FR-04)
- [ ] Фабричные методы (`fileNotFound`, `networkUnavailable`, `premiumRequired`, `timeout`) используют только `L10n.Errors.*` — хардкод строк на EN/RU отсутствует (FR-05, FR-12, NFR-03)
- [ ] `L10n.swift` содержит `enum Errors` с вложенными namespace: `FileSystem`, `Network`, `CloudProvider`, `Auth`, `Parsing`, `StoreKit`, `Sync`, `AI` — покрывающими все строки, которые используются в Stage 2
- [ ] `L10n.Errors` содержит строки для: 4 фабричных методов AppError + 3 ошибки WebDAV + 4 ошибки iCloud + 2 ошибки BookImporter + 7 ошибок KeychainManager (description + recovery для каждой)
- [ ] Ключи формата `"error.file_system.file_not_found.description"` / `"error.file_system.file_not_found.recovery"` добавлены в `en.lproj/Localizable.strings`
- [ ] Те же ключи добавлены в `ru.lproj/Localizable.strings` с русскими переводами
- [ ] Синхронизация: количество `error.*`-ключей одинаково в обоих `.strings`-файлах
- [ ] Проект компилируется без предупреждений Swift 6

**Risks:**
- `Sendable`-соответствие `AppError` при наличии поля `(any Error & Sendable)?` может потребовать явной аннотации `@unchecked Sendable` — документировать в коде
- Ручная реализация `Codable` для `ErrorCode` (8 кейсов-ассоциаций) требует точного маппинга `Category` enum; пропуск кейса вызовет crash при декодировании
- `L10n.Errors` должен содержать ВСЕ строки для Stage 2 заранее — недостающие ключи приведут к ошибкам компиляции на следующем этапе

---

## Stage 2: Миграция существующих throws на AppError + L10n

**Goal:**
Обновить все существующие `throw` в 5 предоставленных файлах:
использовать расширенные `ErrorCode`-кейсы (из Stage 1), заменить
хардкод строк на `L10n.Errors.*`, заполнять `underlyingDescription`
там, где передаётся вложенная ошибка. Обновить `DiagnosticsService`
для использования `analyticsCode` в структурированном логировании.
Публичные сигнатуры протоколов и методов не изменяются.

**Depends on:** Stage 1

**Inputs:**
- `App/Vreader/Vreader/WebDAVProvider.swift`
- `App/Vreader/Vreader/iCloudProvider.swift`
- `App/Vreader/Vreader/BookImporter.swift`
- `App/Vreader/Vreader/KeychainManager.swift`
- `App/Vreader/Vreader/DiagnosticsService.swift`
- `App/Vreader/Vreader/ErrorCode.swift` *(из Stage 1)*
- `App/Vreader/Vreader/AppError.swift` *(из Stage 1)*
- `App/Vreader/Vreader/L10n.swift` *(из Stage 1)*

**Outputs:**
- `App/Vreader/Vreader/WebDAVProvider.swift` *(обновлён)*
- `App/Vreader/Vreader/iCloudProvider.swift` *(обновлён)*
- `App/Vreader/Vreader/BookImporter.swift` *(обновлён)*
- `App/Vreader/Vreader/KeychainManager.swift` *(обновлён)*
- `App/Vreader/Vreader/DiagnosticsService.swift` *(обновлён)*

**DoD:**
- [ ] **WebDAVProvider**: `listFiles` бросает `.cloudProvider(.resourceNotFound)` вместо `.fileSystem(.fileNotFound)`; `download` бросает `.auth(.credentialsMissing)` при отсутствии аутентификации и `.network(.invalidStatusCode)` при не-2xx ответе; все description/recovery через `L10n.Errors.*`
- [ ] **iCloudProvider**: `authenticate`, `listFiles`, `download`, `upload`, `delete`, `getStorageInfo` — все бросают `.auth(.credentialsMissing)` для отсутствующего контейнера; `delete` бросает `.fileSystem(.fileNotFound)`; `waitForUbiquitousDownload` бросает `.fileSystem(.fileNotFound)` и `.network(.timeout)`; все строки через `L10n.Errors.*`
- [ ] **BookImporter**: `importBook` бросает `.parsing(.unsupportedFormat)` и `.fileSystem(.copyFailed)` (не `.permissionDenied`) для ошибки копирования; вложенная ошибка файловой системы записывается в `underlyingDescription`; строки через `L10n.Errors.*`
- [ ] **KeychainManager**: все 7 `throw`-сценариев используют расширенные кейсы: `.auth(.keychainFailed)` вместо `.auth(.keychainUnavailable)`, `.auth(.credentialsMissing)` для item not found; `underlyingDescription` заполняется из OSStatus где возможно; строки через `L10n.Errors.*`
- [ ] **DiagnosticsService**: метод `error(_:context:)` логирует `error.analyticsCode` для структурированного поиска; `containsPII` расширен для проверки `analyticsCode`; уровень логирования `error` применяется корректно
- [ ] Ни один из 5 файлов не содержит хардкода строк на EN/RU в `description:` или `recoveryHint:` — только `L10n.Errors.*`
- [ ] Публичные сигнатуры всех методов (включая методы `CloudProviderProtocol`) не изменены
- [ ] Проект компилируется без предупреждений Swift 6

**Risks:**
- `.auth(.keychainUnavailable)` → `.auth(.keychainFailed)` — переименование кейса может сломать существующие `switch` в других файлах проекта (не в scope задачи). Необходимо оставить `.keychainUnavailable` в `AuthError` как `@available(*, deprecated)` alias **или** убедиться, что нигде кроме предоставленных файлов он не используется
- `waitForUbiquitousDownload` в iCloudProvider использует `Task.sleep` — при обновлении `throw` важно не сломать поток управления внутри цикла
- Замена `.permissionDenied` на `.copyFailed` в `BookImporter` должна быть точечной — не затрагивать другие файлы проекта

---

## Verify
```yaml
- name: Сборка проекта (iOS Simulator)
  command: xcodebuild build -project App/Vreader/Vreader.xcodeproj -scheme Vreader -destination "platform=iOS Simulator,name=iPhone 16" CODE_SIGNING_ALLOWED=NO SWIFT_TREAT_WARNINGS_AS_ERRORS=YES 2>&1 | grep -E "(BUILD SUCCEEDED|BUILD FAILED|error:)" | head -20

- name: Проверка check_refs.py
  command: python3 check_refs.py

- name: Поле underlyingDescription присутствует в AppError (FR-10, FR-17)
  command: grep -c "underlyingDescription" App/Vreader/Vreader/AppError.swift

- name: Поле underlyingError исключено из CodingKeys в AppError (FR-09)
  command: grep -c "underlyingError" App/Vreader/Vreader/AppError.swift | xargs -I{} sh -c 'grep "CodingKeys" App/Vreader/Vreader/AppError.swift | grep -c "underlyingError" || echo 0'

- name: L10n.Errors namespace добавлен (FR-12)
  command: grep -c "enum Errors" App/Vreader/Vreader/L10n.swift

- name: Ключи error.* присутствуют в en Localizable.strings
  command: grep -c "\"error\." App/Vreader/Vreader/en.lproj/Localizable.strings

- name: Ключи error.* присутствуют в ru Localizable.strings и совпадают по количеству
  command: diff <(grep "\"error\." App/Vreader/Vreader/en.lproj/Localizable.strings | sed 's/ =.*//' | sort) <(grep "\"error\." App/Vreader/Vreader/ru.lproj/Localizable.strings | sed 's/ =.*//' | sort)

- name: Отсутствие хардкода строк в фабричных методах AppError (NFR-03)
  command: awk '/static func fileNotFound|static func networkUnavailable|static func premiumRequired|static func timeout/,/^    \}/' App/Vreader/Vreader/AppError.swift | grep -E 'description:|recoveryHint:' | grep -v "L10n\." | wc -l

- name: analyticsCode не содержит скобок и динамических данных (NFR-05)
  command: grep -A5 "var analyticsCode" App/Vreader/Vreader/AppError.swift | grep -v "//" | grep -E '\(|\)|path|token|url' | wc -l
```