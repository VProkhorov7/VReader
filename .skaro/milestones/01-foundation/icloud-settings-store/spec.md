# Specification: icloud-settings-store (обновлённая)

## Context
Архитектура требует хранения настроек в `iCloudSettingsStore` и кэширования `isPremium` с TTL 24 часа. `NSUbiquitousKeyValueStore` требует entitlement `com.apple.developer.ubiquity-kvs-identifier`. Существующий `iCloudSettingsStore.swift` (опечатка в имени) требует исправления и расширения.

**Гибридный подход хранения:**
- **Синхронизируемые через iCloud (NSUbiquitousKeyValueStore):** `currentThemeID`, `isPremiumCache`, `isPremiumCacheTimestamp`, accounts и catalogs (без паролей)
- **Локальное хранилище только (UserDefaults):** `defaultFontSize`, `lineSpacing`, `isAutoScrollEnabled`, а также fallback для всех свойств при недоступности iCloud
- **Keychain (per-device, не синхронизируется):** пароли для accounts, catalogs и WebDAV-провайдеров

## User Scenarios
1. **Пользователь меняет тему на iPhone:** Тема автоматически применяется на iPad через iCloud в течение ~5 секунд.
2. **Устройство offline:** `isPremiumCache` с TTL 24ч используется для разблокировки Premium функций.
3. **TTL кэша истёк и нет сети:** Приложение деградирует до Free tier с понятным сообщением через `PremiumStateValidator`.
4. **Пользователь добавил облачный аккаунт на iPhone:** Метаданные аккаунта (без пароля) синхронизируются на iPad через iCloud; пароль остаётся локально в Keychain iPhone.
5. **Обновление приложения:** Старые параметры (fontSize, fontName, readerTheme, scrollMode, verticalTextMode) автоматически мигрируют в новую схему (currentThemeID, defaultFontSize, lineSpacing, isAutoScrollEnabled).

## Storage Architecture

### Таблица распределения данных

| Данные | NSUbiquitousKeyValueStore | UserDefaults | Keychain | CloudKit |
|--------|---------------------------|--------------|----------|----------|
| `currentThemeID` | ✅ основное | ✅ fallback | ❌ | ❌ |
| `defaultFontSize` | ❌ | ✅ основное | ❌ | ❌ |
| `lineSpacing` | ❌ | ✅ основное | ❌ | ❌ |
| `isAutoScrollEnabled` | ❌ | ✅ основное | ❌ | ❌ |
| `isPremiumCache` | ✅ основное | ✅ fallback | ❌ | ❌ |
| `isPremiumCacheTimestamp` | ✅ основное | ✅ fallback | ❌ | ❌ |
| Accounts (метаданные) | ✅ основное | ✅ fallback | ❌ | ❌ |
| Catalogs (метаданные) | ✅ основное | ✅ fallback | ❌ | ❌ |
| Пароли (accounts, catalogs, WebDAV) | ❌ | ❌ | ✅ per-device | ❌ |

### Graceful Degradation

При отсутствии entitlement `com.apple.developer.ubiquity-kvs-identifier` или недоступности iCloud:
1. Приложение полностью падает на `UserDefaults` для всех свойств
2. Уведомление пользователю (optional, в Settings)
3. Синхронизация между устройствами недоступна (каждое устройство = независимое состояние)

## Functional Requirements

- **FR-01:** `iCloudSettingsStore` — `@Observable` final class, singleton `shared`.

- **FR-02:** Гибридный подход:
  - Попытка записи/чтения в `NSUbiquitousKeyValueStore.default` (если entitlement присутствует и iCloud доступен)
  - Fallback на `UserDefaults` при ошибке или отсутствии entitlement
  - Подписка на `NSUbiquitousKeyValueStore.didChangeExternallyNotification` для синхронизации между устройствами

- **FR-03:** Типизированные свойства (новая схема):
  - `currentThemeID: String` (default: "SystemDefault")
  - `defaultFontSize: Double` (default: 16.0)
  - `lineSpacing: Double` (default: 1.5)
  - `isAutoScrollEnabled: Bool` (default: false)
  - Все свойства — `@Published`, изменения автоматически записываются в хранилище

- **FR-04:** `isPremiumCache: Bool` — кэшированное значение статуса Premium.
  - Хранится в NSUbiquitousKeyValueStore (основное) + UserDefaults (fallback) под ключом `"isPremiumCache"`
  - **ЯВНО документировано:** это НЕ источник истины, только кэш для offline-режима

- **FR-05:** `isPremiumCacheTimestamp: Int` — timestamp инвалидации кэша (unix time в секундах).
  - Хранится в NSUbiquitousKeyValueStore (основное) + UserDefaults (fallback) под ключом `"isPremiumCacheTimestamp"`

- **FR-06:** `isPremiumCacheValid: Bool` (computed property) — возвращает true если кэш не старше 24 часов.
  ```swift
  var isPremiumCacheValid: Bool {
    let now = Int(Date().timeIntervalSince1970)
    let maxAge: Int = 24 * 60 * 60  // 24 часа в секундах
    return (now - isPremiumCacheTimestamp) < maxAge
  }
  ```

- **FR-07:** `setCachedPremium(_ value: Bool)` — сохраняет значение с текущим timestamp.
  - Обновляет `isPremiumCache` и `isPremiumCacheTimestamp` атомарно
  - Записывает в NSUbiquitousKeyValueStore (+ UserDefaults fallback)

- **FR-08:** Подписка на `NSUbiquitousKeyValueStore.didChangeExternallyNotification`:
  - При получении уведомления явно обновить все `@Published` свойства из хранилища
  - `ObservationRegistrar` автоматически уведомит подписчиков View
  - Уведомление приходит при синхронизации с другого устройства в течение ~5 секунд

- **FR-09:** Graceful degradation при недоступности NSUbiquitousKeyValueStore:
  - Полный fallback на `UserDefaults` для всех свойств
  - Нет ошибок в логике, приложение продолжает работать в offline-режиме
  - Статус доступности iCloud может быть доступен через computed property `isCloudSyncAvailable: Bool`

- **FR-10:** Синхронизация accounts и catalogs через iCloud:
  - Метаданные accounts/catalogs (UUID, name, type, URL) хранятся в NSUbiquitousKeyValueStore под ключами `"accounts"` и `"catalogs"` (JSON-массивы)
  - Пароли **остаются** в Keychain (per-device, не синхронизируются)
  - При получении метаданных с iCloud, приложение не пересоздаёт аккаунты, если они уже существуют локально (по UUID)

- **FR-11:** Data migration из старой схемы в новую:
  - При первом запуске приложения версии с новой схемой, автоматически мигрировать:
    - `fontSize` → `defaultFontSize`
    - `fontName` → (игнорировать, fontName не используется в новой схеме)
    - `readerTheme` → `currentThemeID`
    - `scrollMode` → `isAutoScrollEnabled` (если scrollMode == "auto", то true)
    - `verticalTextMode` → (игнорировать, не используется в новой схеме)
  - Миграция выполняется в методе `migrateFromLegacySchema()`, вызываемом при инициализации `iCloudSettingsStore`
  - После миграции старые ключи удаляются из `UserDefaults`

## Non-Functional Requirements

- **NFR-01:** Запись в KVStore < 5ms (для одного свойства).
- **NFR-02:** Максимальный размер хранимых данных в NSUbiquitousKeyValueStore < 1MB (лимит системы).
- **NFR-03:** Синхронизация между устройствами (iCloud) — задержка не более 10 секунд.
- **NFR-04:** Миграция данных при первом запуске — < 100ms.

## Boundaries (что НЕ входит)

- Не хранить credentials (пароли, токены) в NSUbiquitousKeyValueStore или UserDefaults — только Keychain.
- Не синхронизировать `isPremium` через CloudKit или NSUbiquitousKeyValueStore как источник истины (запрещено инвариантом ADR-003).
- Не реализовывать `PremiumStateValidator` — отдельная задача (см. Integration).
- Не хранить iOS-специфичные данные (Device ID, IDFA) в iCloud.

## Integration with Other Components

### PremiumStateValidator
- `iCloudSettingsStore.isPremiumCache` — кэш для offline-режима
- `PremiumStateValidator.validate()` — вызывается при online для получения истины из StoreKit 2
- **Разделение ответственности:**
  - Если online: PremiumStateValidator обновляет iCloudSettingsStore.setCachedPremium()
  - Если offline: приложение использует iCloudSettingsStore.isPremiumCache (если кэш ещё валиден)
  - Если offline и кэш невалиден: деградация до Free tier

### ThemeStore
- `iCloudSettingsStore.currentThemeID` — синхронизируется через iCloud
- `ThemeStore.setTheme(_:isPremiumUser:)` — обновляет `iCloudSettingsStore.currentThemeID`
- При получении внешнего изменения (didChangeExternallyNotification), ThemeStore автоматически переключается на новую тему

### Keychain Manager
- Пароли для accounts, catalogs, WebDAV-провайдеров хранятся в Keychain
- Ключи в Keychain: `"account_\(uuid)"`, `"catalog_\(uuid)"`, `"webdav_\(url)"`
- Синхронизация паролей между устройствами — **НЕ происходит** (per-device по требованию безопасности)

## Data Migration

### Legacy → New Schema
При обнаружении старых ключей в `UserDefaults` при инициализации:
1. Прочитать `fontSize`, `fontName`, `readerTheme`, `scrollMode`, `verticalTextMode`
2. Трансформировать в `currentThemeID`, `defaultFontSize`, `lineSpacing`, `isAutoScrollEnabled`
3. Сохранить в новую схему (NSUbiquitousKeyValueStore + UserDefaults)
4. Удалить старые ключи из `UserDefaults`
5. Записать в логи: "Data migration completed from legacy schema"

### Cross-Device Accounts Sync
Когда `didChangeExternallyNotification` приходит с обновленным accounts/catalogs:
1. Парсить JSON-массив из NSUbiquitousKeyValueStore
2. Для каждого аккаунта: если UUID совпадает с существующим локально, пропустить (не перезаписывать); если новый UUID, добавить
3. Пароли для новых аккаунтов — попросить у пользователя при первом использовании

## Acceptance Criteria

- [ ] Опечатка в имени файла исправлена (`iCloudSettingsStore.swift`).
- [ ] Гибридный подход реализован: NSUbiquitousKeyValueStore + UserDefaults fallback.
- [ ] Свойства currentThemeID, defaultFontSize, lineSpacing, isAutoScrollEnabled — типизированы, @Published, синхронизируются.
- [ ] isPremiumCache и isPremiumCacheTimestamp хранятся отдельными ключами, синхронизируются через iCloud.
- [ ] isPremiumCacheValid корректно инвалидируется через 24 часа.
- [ ] Fallback на UserDefaults работает при отсутствии entitlement или недоступности iCloud.
- [ ] Подписка на didChangeExternallyNotification работает, внешние изменения применяются без перезагрузки приложения.
- [ ] Accounts и catalogs (метаданные без паролей) синхронизируются через iCloud.
- [ ] Пароли для accounts/catalogs остаются в Keychain (per-device).
- [ ] Data migration из старой схемы в новую происходит автоматически при первом запуске.
- [ ] Старые ключи (fontSize, fontName, readerTheme, scrollMode, verticalTextMode) удаляются после миграции.
- [ ] isPremiumCache явно документирован как кэш, НЕ как источник истины.
- [ ] Интеграция с PremiumStateValidator работает: online обновляет кэш, offline использует кэш.
- [ ] Нет credentials (пароли, токены) в NSUbiquitousKeyValueStore или UserDefaults.
- [ ] Запись в KVStore выполняется < 5ms для одного свойства.
- [ ] Синхронизация между устройствами происходит в течение 10 секунд.
- [ ] Юнит-тесты: миграция данных, graceful degradation, TTL инвалидация, didChangeExternallyNotification.
- [ ] Юнит-тесты: fallback на UserDefaults при отсутствии entitlement.

## Open Questions

~~Q1: NSUbiquitousKeyValueStore требует entitlement. Как реализовать FR-02?~~
**A1:** Гибридный подход с полным fallback на UserDefaults. ✅ Закрыто.

~~Q2: Какой набор свойств использовать — из спецификации или существующий?~~
**A2:** Мигрировать на набор из спецификации (currentThemeID, defaultFontSize, lineSpacing, isAutoScrollEnabled) с конверсией старых данных. ✅ Закрыто.

~~Q3: Где хранить timestamp инвалидации TTL?~~
**A3:** Отдельные ключи: 'isPremiumCache' (Bool) + 'isPremiumCacheTimestamp' (Int, unix time) в NSUbiquitousKeyValueStore. ✅ Закрыто.

~~Q4: Для какого подмножества свойств использовать fallback на UserDefaults?~~
**A4:** Все свойства — полный fallback на UserDefaults, NSUbiquitousKeyValueStore = опциональная оптимизация. ✅ Закрыто.

~~Q5: Нужно ли синхронизировать accounts/catalogs через iCloud?~~
**A5:** Синхронизировать через iCloud: accounts/catalogs (без паролей) → NSUbiquitousKeyValueStore, пароли остаются в Keychain (per-device). ✅ Закрыто.

~~Q6: Как интегрировать подписку на didChangeExternallyNotification с @Observable?~~
**A6:** Explicit: в обработчике уведомления обновить @Published свойства вручную, ObservationRegistrar автоматически уведомит подписчиков. ✅ Закрыто.

~~Q7: Как проверяется isPremium в UI? Интеграция с PremiumStateValidator?~~
**A7:** Разделение ответственности: iCloudSettingsStore.isPremiumCache (с TTL) + PremiumStateValidator.validate() вызывается при online. ✅ Закрыто.