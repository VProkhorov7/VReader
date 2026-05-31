# Specification: error-code-system

## Context
Архитектурный инвариант #19 запрещает использование `Error` без `ErrorCode` в публичных API. Каждая ошибка должна содержать код, описание и recovery hint. Существующий `ErrorCode.swift` требует ревизии и расширения.

Дополнительно в рамках этой задачи требуется сохранить совместимость с async-контекстами и сериализацией ошибок. Для этого `AppError` должен оставаться `Codable`, а несериализуемая причина ошибки должна быть представлена отдельно от runtime-поля с исходной ошибкой.

Также в рамках задачи необходимо привести существующие `throw` в предоставленных файлах к использованию `AppError`, не изменяя сигнатуры протоколов и методов.

## User Scenarios
1. **Сервис бросает ошибку:** Вызывающий код получает типизированную ошибку с понятным recovery hint для отображения пользователю.
2. **DiagnosticsService логирует ошибку:** Использует `errorCode` для структурированного логирования без PII.
3. **Ошибка передаётся через async-контекст:** Ошибка безопасно используется в конкурентном коде без нарушения требований Sendable.
4. **Ошибка сериализуется для хранения или передачи:** `AppError` кодируется и декодируется без попытки сериализовать произвольный `Error`.
5. **Существующий код проекта бросает ошибку:** Внутренние `throw` в предоставленных файлах заменены на `AppError`, даже если сигнатуры API по-прежнему используют `throws`.

## Functional Requirements
- FR-01: `AppError` — struct, реализует `Error`, содержит: `code: ErrorCode`, `description: String`, `recoveryHint: String`, `underlyingError: (any Error & Sendable)?`, `underlyingDescription: String?`.
- FR-02: `ErrorCode` — enum с категориями: `.fileSystem(FileSystemError)`, `.network(NetworkError)`, `.cloudProvider(CloudProviderError)`, `.aiService(AIServiceError)`, `.storeKit(StoreKitError)`, `.sync(SyncError)`, `.parsing(ParsingError)`, `.auth(AuthError)`.
- FR-03: Каждая вложенная категория — отдельный enum с конкретными кейсами (например, `FileSystemError`: `.fileNotFound`, `.permissionDenied`, `.bookmarkStale`, `.diskFull`).
- FR-04: `AppError` реализует `LocalizedError` — `errorDescription` возвращает `description`, `recoverySuggestion` возвращает `recoveryHint`.
- FR-05: Статические фабричные методы для частых ошибок: `AppError.fileNotFound(path:)`, `AppError.networkUnavailable()`, `AppError.premiumRequired(feature:)`, `AppError.timeout(service:)`.
- FR-06: `ErrorCode` реализует `Equatable` и `Hashable`.
- FR-07: `AppError` содержит `var analyticsCode: String` — безопасный для логирования код без PII.
- FR-08: `AppError` реализует `Codable`.
- FR-09: Поле `underlyingError` не участвует в `Codable` и используется только как runtime-контекст для in-memory error chaining.
- FR-10: Поле `underlyingDescription` используется как сериализуемое текстовое представление первопричины ошибки и может заполняться из `underlyingError` или передаваться явно.
- FR-11: `analyticsCode` должен формироваться только в стабильном формате `category.case` без дополнительных деталей, параметров, путей, токенов, идентификаторов пользователей или иного контекста.
- FR-12: Все новые пользовательские строки для `description` и `recoveryHint` должны быть сразу добавлены в `L10n` и, при необходимости, в `Localizable.strings` для поддерживаемых локализаций.
- FR-13: В рамках задачи необходимо обновить существующие `throw` в предоставленных файлах так, чтобы они бросали `AppError`, не изменяя публичные сигнатуры протоколов, методов и функций.
- FR-14: Вложенные enum-категории ошибок должны содержать не только демонстрационные кейсы, но и расширенный практический набор кейсов, покрывающий уже существующие сценарии проекта.
- FR-15: `ErrorCode` и все вложенные enum-категории должны реализовывать `Sendable` для безопасного использования в async-контексте.
- FR-16: `AppError` должен быть `Sendable` в той мере, в какой это допускает состав полей и модель Swift 6; реализация не должна вызывать предупреждений компилятора Swift 6.
- FR-17: Для `Codable`-представления `AppError` должны сериализоваться как минимум поля `code`, `description`, `recoveryHint`, `underlyingDescription`; поле `underlyingError` должно исключаться из кодирования и декодирования.
- FR-18: Должен быть определён явный контракт error chaining: runtime-цепочка хранится через `underlyingError`, а сериализуемая/диагностическая цепочка — через `underlyingDescription`; этого механизма достаточно в рамках данной задачи.

## Recommended Error Cases
Ниже приведён минимально-расширенный практический набор кейсов, который должен быть учтён при проектировании вложенных enum-типов. Допускается расширение без удаления перечисленных кейсов.

### FileSystemError
- `.fileNotFound`
- `.permissionDenied`
- `.bookmarkStale`
- `.diskFull`
- `.readFailed`
- `.writeFailed`
- `.deleteFailed`
- `.moveFailed`
- `.copyFailed`
- `.createDirectoryFailed`
- `.invalidPath`
- `.fileAlreadyExists`
- `.fileAccessDenied`

### NetworkError
- `.unavailable`
- `.offline`
- `.timeout`
- `.cancelled`
- `.invalidResponse`
- `.invalidStatusCode`
- `.requestFailed`
- `.downloadFailed`
- `.uploadFailed`
- `.decodingFailed`
- `.encodingFailed`
- `.rateLimited`
- `.serverError`

### CloudProviderError
- `.providerUnavailable`
- `.credentialsMissing`
- `.authenticationFailed`
- `.authorizationFailed`
- `.accountNotFound`
- `.resourceNotFound`
- `.quotaExceeded`
- `.conflict`
- `.invalidResponse`
- `.unsupportedProvider`
- `.syncFailed`
- `.downloadFailed`
- `.uploadFailed`

### AIServiceError
- `.apiKeyMissing`
- `.apiKeyInvalid`
- `.requestFailed`
- `.invalidResponse`
- `.rateLimited`
- `.quotaExceeded`
- `.modelUnavailable`
- `.contentBlocked`
- `.unsupportedLanguage`
- `.generationFailed`
- `.timeout`

### StoreKitError
- `.productNotFound`
- `.purchaseFailed`
- `.purchaseCancelled`
- `.verificationFailed`
- `.premiumRequired`
- `.restoreFailed`
- `.receiptMissing`
- `.receiptInvalid`
- `.notEntitled`

### SyncError
- `.conflictDetected`
- `.mergeFailed`
- `.cloudUnavailable`
- `.pushFailed`
- `.pullFailed`
- `.invalidState`
- `.versionMismatch`
- `.serializationFailed`
- `.deserializationFailed`

### ParsingError
- `.unsupportedFormat`
- `.invalidFormat`
- `.corruptedData`
- `.missingRequiredField`
- `.decodingFailed`
- `.encodingFailed`
- `.emptyContent`
- `.unsupportedEncoding`
- `.metadataExtractionFailed`

### AuthError
- `.credentialsMissing`
- `.invalidCredentials`
- `.tokenExpired`
- `.tokenMissing`
- `.refreshFailed`
- `.accessDenied`
- `.sessionExpired`
- `.biometryUnavailable`
- `.biometryFailed`
- `.keychainFailed`

## Non-Functional Requirements
- NFR-01: Все строки описаний и hints через `L10n.*` (или константы, заменяемые на L10n в milestone локализации).
- NFR-02: Компилируется в Swift 6 без предупреждений.
- NFR-03: Все новые строки ошибок должны быть добавлены в `L10n` сразу в рамках этой задачи; временные локальные константы с `TODO` для новых пользовательских строк не допускаются.
- NFR-04: `analyticsCode` должен быть стабилен между запусками и версиями, если семантика ошибки не изменилась.
- NFR-05: `analyticsCode` не должен содержать PII, пути к файлам, URL с токенами, query-параметры, имена аккаунтов, идентификаторы документов, текст запросов или иные пользовательские данные.
- NFR-06: Реализация `Codable` и `Sendable` не должна требовать небезопасных допущений без явного документирования в коде.

## Boundaries (что НЕ входит)
- Не реализовывать UI для отображения ошибок.
- Не реализовывать DiagnosticsService.
- Не изменять публичные сигнатуры протоколов, методов и функций ради замены `throws` на `throws(AppError)` или иных изменений типа ошибки.
- Не требуется реализовывать произвольную глубокую сериализацию всей цепочки вложенных ошибок beyond `underlyingDescription`.

## Acceptance Criteria
- [ ] `AppError` и `ErrorCode` определены и компилируются.
- [ ] Все 8 категорий ошибок присутствуют.
- [ ] Фабричные методы работают корректно.
- [ ] `analyticsCode` не содержит путей к файлам или токенов.
- [ ] Существующий `ErrorCode.swift` заменён или обновлён без дублирования типов.
- [ ] `AppError` сохраняет `Codable`-совместимость.
- [ ] `underlyingError` имеет тип `(any Error & Sendable)?`.
- [ ] `underlyingError` не сериализуется в `Codable`.
- [ ] `underlyingDescription: String?` сериализуется и декодируется корректно.
- [ ] `AppError` реализует `LocalizedError` и возвращает `description`/`recoveryHint` через `errorDescription`/`recoverySuggestion`.
- [ ] `analyticsCode` формируется строго в формате `category.case`.
- [ ] `analyticsCode` не содержит контекст фабричного метода, пользовательские данные или иные нестабильные детали.
- [ ] Все новые строки ошибок добавлены в `L10n`.
- [ ] При необходимости новые строки добавлены в `Localizable.strings` для `ru` и `en`.
- [ ] Вложенные enum-категории покрывают расширенный практический набор кейсов, используемый текущим кодом проекта.
- [ ] Существующие `throw` в предоставленных файлах заменены на `AppError` без изменения сигнатур протоколов и методов.
- [ ] `ErrorCode` и вложенные enum-ошибки реализуют `Equatable`, `Hashable` и `Sendable`.
- [ ] Решение компилируется в Swift 6 без предупреждений.
- [ ] Error chaining поддерживается через runtime-поле `underlyingError` и сериализуемое поле `underlyingDescription`.

## Open Questions
Решено в рамках данной спецификации:
- `AppError` должен оставаться `Codable`; для этого добавляется сериализуемое поле `underlyingDescription: String?`, а `underlyingError` исключается из `Codable`.
- Для безопасного использования в async-коде используется `underlyingError: (any Error & Sendable)?`.
- Цепочки ошибок считаются достаточно покрытыми комбинацией `underlyingError` + `underlyingDescription`.
- `ErrorCode` и вложенные enum-ошибки должны быть `Sendable`.