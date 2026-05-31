# Constitution: VReader

## Stack
- Language: Swift 5.0 (SWIFT_VERSION = 5.0), Swift Concurrency включён (SWIFT_APPROACHABLE_CONCURRENCY = YES)
- Framework: SwiftUI + SwiftData; PDFKit, AVFoundation, WebKit, ZIPFoundation 0.9.20; iOS/macOS/visionOS (SUPPORTED_PLATFORMS = "iphoneos iphonesimulator macosx xros xrsimulator")
- Database: SwiftData (ModelContainer, @Model — класс Book); Keychain (KeychainManager actor) для секретов; UserDefaults для настроек ридера; NSUbiquitousKeyValueStore для iCloud-синхронизации настроек
- Infrastructure: iCloud (CloudDocuments + KVS), App Groups (group.$(CFBundleIdentifier)), Xcode 26.2, Deployment Target iOS/macOS 26.2

## Coding Standards
- Linter: не обнаружен явный конфиг (swiftlint.yml отсутствует); в CLAUDE.md указано «Avoid unrelated formatting changes»
- Formatter: SwiftFormat упомянут в хуке `.claude/hooks/format-touched.sh` как опциональный («Add swiftformat here if installed»), фактически не применяется автоматически
- Naming: UpperCamelCase для типов (Book, AppError, ThemeStore); lowerCamelCase для свойств и методов; файлы именуются по типу (BookCardView.swift, EPUBReaderView.swift); расширения — через `+` (Book+Computed.swift, Book+SampleData.swift); приватные вложенные типы — через вложение в struct/class; протоколы заканчиваются на Protocol (CloudProviderProtocol) или описывают роль (AppTheme, ContentSource)
- Max function length: не задан явно; наблюдаемый паттерн — функции до ~50 строк, крупные View разбиваются на @ViewBuilder-секции (coverSection, metaSection, bottomActionBar)
- Max nesting depth: не задан явно; наблюдаемый максимум — 4–5 уровней вложенности в SwiftUI-иерархиях

## Testing
- Minimum coverage: не задан
- Framework: Swift Testing (@Test, #expect) для юнит-тестов (VreaderTests); XCTest для UI-тестов (VreaderUITests)
- Required: тесты KeychainManager (save/load/delete/exists, типизированные ключи KeychainKey, коллизии строк и данных); тесты ThemeStore (доступность тем, premium-блокировка, персистентность, Codable round-trip ThemeID); UI-тесты — запуск приложения и скриншот при старте

## Constraints
- Активная кодовая база — `App/Vreader/Vreader/`; директория `Vreader/` (корень) является устаревшей (legacy), не использовать для новых изменений
- Файл `Vreader/Untitled.swift` исключён из компиляции через PBXFileSystemSynchronizedBuildFileExceptionSet
- Модель Book в App-версии использует `coverPath: String?` (путь к файлу обложки); в legacy-версии — `coverData: Data?`; check_refs.py блокирует `coverData: Data` в SwiftData-модели
- Форматы книг: PDF, EPUB, FB2, TXT, RTF, CBZ, CBR, CB7, CBT, MOBI, AZW3, DjVu, CHM, MP3, M4A, M4B — все перечислены в BookFormat; CHM не читается нативно (проприетарный LZX), отображается заглушка
- Тема приложения передаётся через Environment (AppThemeKey); смена темы — только через ThemeStore.setTheme(_:isPremiumUser:); premium-темы (NeuralLink, Typewriter) требуют isPremiumUser = true
- isPremium не должен синхронизироваться через CloudKit/CKRecord (проверяется check_refs.py)
- OAuth (Google Drive, Dropbox, OneDrive) — не реализован, только WebDAV-провайдеры; для OAuth обязателен ASWebAuthenticationSession, WKWebView для OAuth запрещён (check_refs.py)
- Все пользовательские строки должны идти через L10n.* (enum L10n с String(localized:defaultValue:)); жёстко закодированные строки в UI-компонентах фиксируются check_refs.py как предупреждения
- Локализации: ru (основной язык), en; файлы Localizable.strings в en.lproj и ru.lproj
- Keychain: OAuth-токены (Google, Dropbox, OneDrive) — isSynchronizable = true, kSecAttrAccessibleAfterFirstUnlock; локальные ключи (Gemini API, WebDAV/SMB пароли) — isSynchronizable = false, kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
- SwiftData schema version хранится в UserDefaults (db.schemaVersion = 2); при несовместимом изменении модели — инкрементировать версию, база пересоздаётся
- Запрещены: rm -rf /, git push --force, sudo, chmod 777, curl|sh, wget|sh (блокируется .claude/hooks/block-danger.sh)
- Запрещено читать: .env, .env.*, secrets, сертификаты, provisioning profiles, SSH-ключи
- Не читать DerivedData/, build/, .build/, Pods/ (deny в .claude/settings.json)
- Репозитории VReader и GEO держать раздельно, не смешивать remote URL

## Security
- Authorization: Keychain (actor KeychainManager) — единственное хранилище паролей и токенов; пароли облачных аккаунтов сохраняются по ключу keychainKey = "provider_\(type)_\(uuid)"; OPDS-пароли — по "catalog_\(uuid)"
- Input validation: проверка формата файла при импорте (BookFormat(url:) возвращает nil для неподдерживаемых расширений → AppError(.parsing(.unsupportedFormat))); проверка HTTP-статуса при WebDAV (207 для PROPFIND, 200–299 для download); проверка доступности iCloud-контейнера перед операциями
- Secrets: API-ключи и токены — только в Keychain (KeychainManager); никогда не логировать ключи, токены, base URL с секретами (явно указано в .claude/rules/api-rules.md и CLAUDE.md); .env и .env.* исключены из чтения

## LLM Rules
- Не оставлять заглушки без явного TODO с обоснованием (пример допустимого: `// TODO: migrate to L10n.* in milestone 09`)
- Не дублировать код: предпочитать переиспользование и чёткие абстракции; вычисляемые свойства Book выносить в Book+Computed.swift, тестовые данные — в Book+SampleData.swift (#if DEBUG)
- Не делать скрытых предположений — при неясности в архитектуре спрашивать перед реализацией
- Всегда следовать стилю кода, описанному выше: UpperCamelCase типы, lowerCamelCase свойства, расширения через `+`, MARK-секции для разделения логики
- Перед публикацией изменений запускать check_refs.py (Description/check_refs.py или check_refs.py в корне); при ошибках — сначала исправлять, потом коммитить
- Зависимые файлы публиковать одним пакетом (например, Book.swift + Book+Computed.swift при изменении модели)
- Изменять только файлы в `App/Vreader/Vreader/`; директорию `Vreader/` (legacy) не трогать без явного указания
- Делать атомарные минимальные изменения; не рефакторить без явного запроса; не переписывать целые файлы без необходимости
- Не добавлять новые зависимости (Swift Package) без явного одобрения
- Ответ после правок: только «Done» или «Updated X files» — без дополнительных объяснений, если не запрошено
- Генерировать AI_NOTES.md по шаблону при каждом значимом архитектурном решении