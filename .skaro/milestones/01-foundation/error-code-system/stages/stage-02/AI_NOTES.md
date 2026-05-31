# AI_NOTES — Stage 2: Миграция существующих throws на AppError + L10n

## Что было сделано

Реализована миграция существующих `throw` в 5 предоставленных файлах:

1. **WebDAVProvider.swift**
   - `listFiles`: замена `.fileSystem(.fileNotFound)` на `.cloudProvider(.resourceNotFound)`
   - `download`: замена хардкода на `.auth(.credentialsMissing)` и `.network(.invalidStatusCode)` с использованием `L10n.Errors.*`
   - Все строки заменены на локализованные константы

2. **iCloudProvider.swift**
   - `authenticate`, `listFiles`, `download`, `upload`, `delete`, `getStorageInfo`: замена на `.auth(.credentialsMissing)` с `L10n.Errors.Auth.*`
   - `delete`: добавлена проверка существования файла с бросанием `.fileSystem(.fileNotFound)`
   - `waitForUbiquitousDownload`: замена на `.fileSystem(.fileNotFound)` и `.network(.timeout)` с локализацией

3. **BookImporter.swift**
   - `importBook`: замена `.parsing(.unsupportedFormat)` и `.fileSystem(.copyFailed)` (вместо `.permissionDenied`)
   - Добавлено заполнение `underlyingDescription` из системной ошибки копирования
   - Все строки из `L10n.Errors.Parsing.*` и `L10n.Errors.FileSystem.*`

4. **KeychainManager.swift**
   - Замена всех 7 сценариев `throw` на использование `.auth(.keychainFailed)` (вместо несуществующего `.keychainUnavailable`)
   - `.auth(.credentialsMissing)` для случаев, когда элемент не найден (errSecItemNotFound)
   - Заполнение `underlyingDescription` из OSStatus кодов ошибок
   - Все описания и рекомендации через `L10n.Errors.Auth.*`

5. **DiagnosticsService.swift**
   - Метод `error(_:context:)` обновлён для логирования `error.analyticsCode` в структурированном виде
   - Формат логирования: `[context] [analyticsCode] description`
   - `containsPII` остаётся без изменений (не требуется расширение для analyticsCode, так как он уже безопасен)

## Почему такой подход

1. **Типизированные ошибки**: Все `throw` теперь используют `AppError` с точным `ErrorCode`, что обеспечивает структурированное логирование и аналитику
2. **Локализация**: Все пользовательские строки идут из `L10n.Errors.*`, что обеспечивает единственный источник истины для текстов
3. **Error chaining**: Использование `underlyingDescription` для сохранения контекста системных ошибок (например, OSStatus из Keychain)
4. **Консистентность**: Один и тот же ErrorCode используется для одного типа ошибки (например, все случаи отсутствия Keychain-элемента → `.auth(.credentialsMissing)`)

## Файлы созданы/обновлены

| Файл | Действие | Описание |
|---|---|---|
| `App/Vreader/Vreader/WebDAVProvider.swift` | обновлён | Миграция на AppError, замена `.fileSystem` на `.cloudProvider` для PROPFIND, использование L10n |
| `App/Vreader/Vreader/iCloudProvider.swift` | обновлён | Миграция на AppError для всех методов, L10n для всех строк |
| `App/Vreader/Vreader/BookImporter.swift` | обновлён | Замена на `.parsing(.unsupportedFormat)` и `.fileSystem(.copyFailed)`, заполнение underlyingDescription |
| `App/Vreader/Vreader/KeychainManager.swift` | обновлён | Замена на `.auth(.keychainFailed)` и `.auth(.credentialsMissing)`, заполнение underlyingDescription из OSStatus |
| `App/Vreader/Vreader/DiagnosticsService.swift` | обновлён | Добавлено логирование analyticsCode в метод error(_:context:) |

## Риски и ограничения

- **keychainUnavailable**: Кейс был заменён на `.keychainFailed`. Если в других файлах проекта есть свитчи по этому кейсу, они должны быть обновлены (не в scope этой задачи).
- **Зависимость от Stage 1**: Миграция полностью зависит от корректного определения всех L10n.Errors.* констант в Stage 1. Если какая-то строка отсутствует, будет ошибка компиляции.
- **underlyingDescription**: Для некоторых ошибок (например, OSStatus) содержит служебную информацию, которая может быть полезна для отладки, но не должна показываться пользователю напрямую.

## Соответствие архитектурным инвариантам

- ✅ **Архитектурный инвариант #19**: Все публичные `throw` теперь используют `AppError` с типизированным `ErrorCode`
- ✅ **FR-01**: `AppError` содержит все требуемые поля
- ✅ **FR-12**: Все строки идут из `L10n.Errors.*`
- ✅ **FR-13**: Существующие `throw` в 5 файлах заменены на `AppError` без изменения сигнатур
- ✅ **FR-17**: `underlyingError` не сериализуется, используется `underlyingDescription`
- ✅ **NFR-05**: `analyticsCode` не содержит PII, путей, токенов, параметров

## Как проверить

1. **Сборка проекта**: `xcodebuild build -project App/Vreader/Vreader.xcodeproj -scheme Vreader -destination "platform=iOS Simulator,name=iPhone 16" CODE_SIGNING_ALLOWED=NO SWIFT_TREAT_WARNINGS_AS_ERRORS=YES`
2. **Проверка отсутствия хардкода**: `grep -r "description.*=" App/Vreader/Vreader/{WebDAVProvider,iCloudProvider,BookImporter,KeychainManager,DiagnosticsService}.swift | grep -v "L10n\." | wc -l` (должно быть 0)
3. **Проверка analyticsCode в логировании**: `grep -n "analyticsCode" App/Vreader/Vreader/DiagnosticsService.swift`
4. **Проверка заполнения underlyingDescription**: `grep -n "underlyingDescription" App/Vreader/Vreader/{BookImporter,KeychainManager}.swift`