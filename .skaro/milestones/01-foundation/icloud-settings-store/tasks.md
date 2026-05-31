```markdown
# Tasks: icloud-settings-store

## Stage 1: Ядро iCloudSettingsStore + интеграция ThemeStore и SettingsView

- [ ] Переработать `iCloudSettingsStore` в `@Observable @MainActor final class` с singleton `shared` → `App/Vreader/Vreader/iCloudSettingsStore.swift`
- [ ] Добавить `#if DEBUG` init с инъекцией `UserDefaults` для изоляции в тестах → `App/Vreader/Vreader/iCloudSettingsStore.swift`
- [ ] Реализовать гибридные вспомогательные методы `saveToStore` / `loadFromStore` с guard `isCloudSyncAvailable` → `App/Vreader/Vreader/iCloudSettingsStore.swift`
- [ ] Добавить синхронизируемые свойства: `currentThemeID: String`, `isPremiumCache: Bool`, `isPremiumCacheTimestamp: Int`, `connectedAccounts`, `connectedCatalogs` → `App/Vreader/Vreader/iCloudSettingsStore.swift`
- [ ] Добавить локальные свойства: `defaultFontSize: Double`, `lineSpacing: Double`, `isAutoScrollEnabled: Bool` (только UserDefaults) → `App/Vreader/Vreader/iCloudSettingsStore.swift`
- [ ] Реализовать `isPremiumCacheValid: Bool` (TTL 24ч через unix timestamp) с документацией "НЕ источник истины" → `App/Vreader/Vreader/iCloudSettingsStore.swift`
- [ ] Реализовать `setCachedPremium(_ value: Bool)` — атомарное обновление `isPremiumCache` + `isPremiumCacheTimestamp` → `App/Vreader/Vreader/iCloudSettingsStore.swift`
- [ ] Реализовать `isCloudSyncAvailable: Bool` через `FileManager.default.ubiquityIdentityToken != nil` → `App/Vreader/Vreader/iCloudSettingsStore.swift`
- [ ] Подписаться на `NSUbiquitousKeyValueStore.didChangeExternallyNotification` с `queue: .main`; обработчик обновляет все `@Observable` свойства → `App/Vreader/Vreader/iCloudSettingsStore.swift`
- [ ] Реализовать `migrateFromLegacySchema()`: `fontSize`→`defaultFontSize`, `readerTheme`→`currentThemeID`, `scrollMode`→`isAutoScrollEnabled`; удаление старых ключей; запись в лог → `App/Vreader/Vreader/iCloudSettingsStore.swift`
- [ ] Реализовать cross-device merge для accounts: при `didChangeExternallyNotification` добавлять только аккаунты с новыми UUID → `App/Vreader/Vreader/iCloudSettingsStore.swift`
- [ ] Сохранить публичный API управления аккаунтами: `addAccount`, `removeAccount`, `password(for:)` → `App/Vreader/Vreader/iCloudSettingsStore.swift`
- [ ] Сохранить публичный API управления каталогами: `addCatalog`, `removeCatalog`, `catalogPassword(for:)`, `isCatalogConnected(_:)` → `App/Vreader/Vreader/iCloudSettingsStore.swift`
- [ ] Обновить `ThemeStore`: удалить `userDefaults`, удалить TODO, добавить `init(settingsStore: iCloudSettingsStore = .shared)` → `App/Vreader/Vreader/ThemeStore.swift`
- [ ] Сделать `currentThemeID` в `ThemeStore` computed-св