## plan.md

## Stage 1: Ядро iCloudSettingsStore + интеграция ThemeStore и SettingsView

**Goal:** Переработать `iCloudSettingsStore` в гибридное хранилище (`@Observable`,
NSUbiquitousKeyValueStore + UserDefaults fallback). Обновить `ThemeStore` для делегирования
персистентности в `iCloudSettingsStore`. Обновить `SettingsView` под новые свойства.
Задокументировать архитектурное решение в `AI_NOTES.md`.

**Depends on:** нет

**Inputs:**
- `App/Vreader/Vreader/iCloudSettingsStore.swift` (существующий — полная переработка)
- `App/Vreader/Vreader/ThemeStore.swift` (существующий — замена UserDefaults на iCloudSettingsStore)
- `App/Vreader/Vreader/SettingsView.swift` (существующий — обновление имён свойств)
- `App/Vreader/Vreader/VReader.entitlements` (entitlement `ubiquity-kvs-identifier` уже присутствует)
- `App/Vreader/Vreader/KeychainManager.swift` (только для чтения — API паролей)
- `App/Vreader/Vreader/ThemeID.swift` (только для чтения — enum ThemeID)
- `AI_NOTES.md` (обновление)
- Спецификация, Архитектура, ADR-003, ADR-009

**Outputs:**
- `App/Vreader/Vreader/iCloudSettingsStore.swift`
- `App/Vreader/Vreader/ThemeStore.swift`
- `App/Vreader/Vreader/SettingsView.swift`
- `AI_NOTES.md`

**DoD:**
- [ ] `iCloudSettingsStore` — `@Observable @MainActor final class`, singleton `shared`
- [ ] Принимает инъекцию `UserDefaults` (параметр `defaults`) для изоляции в тестах (#if DEBUG init)
- [ ] Гибридное хранилище: `currentThemeID`, `isPremiumCache`, `isPremiumCacheTimestamp`, `accounts`, `catalogs` — NSUbiquitousKeyValueStore (основное) + UserDefaults (fallback при недоступности KVStore)
- [ ] Только UserDefaults: `defaultFontSize` (default 16.0), `lineSpacing` (default 1.5), `isAutoScrollEnabled` (default false)
- [ ] `isPremiumCacheValid: Bool` — TTL 24 часа через сравнение unix timestamp
- [ ] `setCachedPremium(_ value: Bool)` — атомарно обновляет `isPremiumCache` и `isPremiumCacheTimestamp`
- [ ] `isCloudSyncAvailable: Bool` — проверяет `FileManager.default.ubiquityIdentityToken != nil`
- [ ] Подписка на `NSUbiquitousKeyValueStore.didChangeExternallyNotification` через `NotificationCenter` с `queue: .main`; обработчик обновляет все `@Observable` свойства на `@MainActor`
- [ ] Graceful degradation: `saveToStore` / `loadFromStore` — при `!isCloudSyncAvailable` все операции идут через `UserDefaults`; никаких бросаемых ошибок в UI-пути
- [ ] `migrateFromLegacySchema()` вызывается при `init`: `fontSize` → `defaultFontSize`, `readerTheme` → `currentThemeID`, `scrollMode == "auto"` → `isAutoScrollEnabled = true`; после миграции старые ключи удаляются из UserDefaults; пишет в лог "Миграция из legacy-схемы завершена"
- [ ] Accounts/catalogs: JSON-массивы в NSUbiquitousKeyValueStore (ключи `"accounts"`, `"catalogs"`) + UserDefaults fallback; пароли исключительно в `KeychainManager`
- [ ] Cross-device merge accounts: при `didChangeExternallyNotification` добавляются только аккаунты с новыми UUID, существующие не перезаписываются
- [ ] `ThemeStore` удаляет `userDefaults` и TODO-комментарий; принимает `iCloudSettingsStore` через `init(settingsStore:)` для тестируемости; `currentThemeID` — computed через `settingsStore.currentThemeID`; `setTheme` пишет в `settingsStore.currentThemeID`
- [ ] `SettingsView` использует `settings.defaultFontSize` вместо `settings.fontSize`, `settings.currentThemeID` вместо `settings.readerTheme`, `settings.isAutoScrollEnabled` вместо `settings.scrollMode`; `@StateObject` заменён на `@State` (совместимо с `@Observable`)
- [ ] Нет credentials (паролей, токенов) в NSUbiquitousKeyValueStore или UserDefaults
- [ ] `isPremiumCache` явно документирован в комментарии: "НЕ источник истины — только кэш для offline-режима"
- [ ] `isPremium` синхронизация через KVStore используется только как кэш (не источник истины, ADR-003)
- [ ] `AI_NOTES.md` содержит запись о гибридной архитектуре хранилища настроек

**Risks:**
- `NSUbiquitousKeyValueStore` недоступен в симуляторе без iCloud аккаунта — все пути чтения/записи обязаны иметь `isCloudSyncAvailable` guard перед обращением к KVStore
- `@Observable` + computed property через внешний `@Observable` объект: SwiftUI корректно отслеживает цепочку доступов — проверить что `themeStore.currentTheme` инвалидируется при изменении `settingsStore.currentThemeID`
- Обратная совместимость: `CloudStorageView`, `CatalogsView`, `OnlineView` используют `connectedAccounts`/`connectedCatalogs` — имена и типы свойств не меняются, только механизм персистентности

---

## Stage 2: Юнит-тесты iCloudSettingsStore

**Goal:** Покрыть тестами ключевые пути: миграция legacy-схемы, graceful degradation
(UserDefaults fallback), TTL инвалидация, атомарность `setCachedPremium`,
симуляция внешних изменений, управление аккаунтами и каталогами.

**Depends on:** Stage 1

**Inputs:**
- `App/Vreader/VreaderTests/VreaderTests.swift` (существующий — добавить тесты)
- Реализация из Stage 1

**Outputs:**
- `App/Vreader/VreaderTests/VreaderTests.swift`

**DoD:**
- [ ] Все тесты используют `UserDefaults(suiteName: "test.\(UUID().uuidString)")!` для полной изоляции
- [ ] `@Test func migrationFromLegacySchema()` — предзаполняет старые ключи (`reader.fontSize`, `reader.readerTheme`, `reader.scrollMode`), создаёт `iCloudSettingsStore(defaults:)`, проверяет что новые свойства содержат мигрированные значения, старые ключи удалены
- [ ] `@Test func gracefulDegradationToUserDefaults()` — при `isCloudSyncAvailable == false` запись/чтение идут через UserDefaults без ошибок; значение сохраняется и восстанавливается
- [ ] `@Test func isPremiumCacheValidTTL()` — `setCachedPremium(true)` → `isPremiumCacheValid == true`; подделка `isPremiumCacheTimestamp` (> 24ч назад) → `isPremiumCacheValid == false`
- [ ] `@Test func setCachedPremiumAtomicity()` — после вызова `setCachedPremium(true)` оба поля (`isPremiumCache`, `isPremiumCacheTimestamp`) ненулевые и согласованные
- [ ] `@Test func externalChangeNotificationUpdatesProperties()` — вручную пишем в `UserDefaults` тестового экземпляра, постим `NSUbiquitousKeyValueStore.didChangeExternallyNotification`, проверяем что `@Observable` свойства обновились
- [ ] `@Test func addAndRemoveAccount()` — `addAccount` добавляет аккаунт в `connectedAccounts`; `removeAccount` удаляет; после удаления `connectedAccounts.count` уменьшается на 1
- [ ] `@Test func addAndRemoveCatalog()` — аналогично для `connectedCatalogs`
- [ ] `@Test func isCatalogConnectedReturnsCorrectValue()` — до добавления `false`, после `addCatalog` — `true`, после `removeCatalog` — `false`
- [ ] `@Test func crossDeviceMergeSkipsDuplicateUUIDs()` — если аккаунт с данным UUID уже существует, повторное добавление через merge-путь его не дублирует
- [ ] Используется Swift Testing (`@Test`, `#expect`, `#require`)
- [ ] Нет зависимости от реального NSUbiquitousKeyValueStore в тестах

**Risks:**
- `@MainActor` singleton нельзя переинициализировать между тестами — тесты используют `#if DEBUG init(defaults:)`, создавая независимые non-singleton экземпляры
- `didChangeExternallyNotification` в тестах требует ручной публикации через `NotificationCenter.default.post` — KVStore не участвует

---

## Verify
- name: Сборка проекта (iOS, без подписи)
  command: xcodebuild build -project App/Vreader/Vreader.xcodeproj -scheme Vreader -destination 'generic/platform=iOS' CODE_SIGNING_ALLOWED=NO 2>&1 | grep -E '(BUILD SUCCEEDED|BUILD FAILED|error:)' | head -20
- name: Юнит-тесты VreaderTests
  command: xcodebuild test -project App/Vreader/Vreader.xcodeproj -scheme Vreader -destination 'platform=iOS Simulator,name=iPhone 16' -only-testing:VreaderTests 2>&1 | grep -E '(Test Suite|passed|failed|error:)' | head -30
- name: Проверка отсутствия isPremium в CloudKit (check_refs)
  command: python3 check_refs.py 2>&1 | grep -E '(ERROR|WARNING|OK)' | head -20