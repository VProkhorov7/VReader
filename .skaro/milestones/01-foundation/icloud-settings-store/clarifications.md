# Clarifications: 01-foundation::icloud-settings-store

## Question 1
NSUbiquitousKeyValueStore требует entitlement 'com.apple.developer.ubiquity-kvs-identifier'. Текущий код использует только UserDefaults. Как реализовать FR-02?

*Context:* Определяет основную архитектуру хранилища: полная миграция на iCloud KVS vs гибридный подход (KVS для синхронизируемых, UserDefaults для локальных)

**Options:**
- A) Полная миграция: все свойства → NSUbiquitousKeyValueStore, UserDefaults только как fallback при отсутствии entitlement
- B) Гибридный подход: currentThemeID, isPremiumCache → NSUbiquitousKeyValueStore; fontSize, fontName, accounts → UserDefaults (локально)
- C) Только isPremiumCache → NSUbiquitousKeyValueStore; остальное → UserDefaults как сейчас (минимальные изменения)

**Answer:**
Гибридный подход: currentThemeID, isPremiumCache → NSUbiquitousKeyValueStore; fontSize, fontName, accounts → UserDefaults (локально)

## Question 2
FR-03 перечисляет свойства (currentThemeID, defaultFontSize, lineSpacing, isAutoScrollEnabled), но существующий код имеет fontSize, fontName, readerTheme, scrollMode, verticalTextMode. Какой набор использовать?

*Context:* Определяет совместимость с существующим кодом и ThemeStore, которые уже используют readerTheme и currentThemeID

**Options:**
- A) Сохранить существующий набор (fontSize, fontName, readerTheme, scrollMode, verticalTextMode) как источник истины
- B) Мигрировать на набор из спецификации (currentThemeID, defaultFontSize, lineSpacing, isAutoScrollEnabled) с конверсией старых данных
- C) Расширенный набор: оба варианта + новые (isAutoScrollEnabled), deprecated старые с миграцией

**Answer:**
Мигрировать на набор из спецификации (currentThemeID, defaultFontSize, lineSpacing, isAutoScrollEnabled) с конверсией старых данных

## Question 3
FR-04/FR-06: TTL 24 часа для isPremiumCache. Где и как хранить timestamp инвалидации?

*Context:* Определяет механизм кэширования: простой boolean vs структура с TTL, и как синхронизировать timestamp через iCloud

**Options:**
- A) Отдельные ключи: 'isPremiumCache' (Bool) + 'isPremiumCacheTimestamp' (Int, unix time) в NSUbiquitousKeyValueStore
- B) Кодируемая структура PremiumCacheEntry(value: Bool, expiresAt: Date) в NSUbiquitousKeyValueStore как JSON Data
- C) Только в памяти: @Published свойство с локальным timestamp, NSUbiquitousKeyValueStore только для значения

**Answer:**
Отдельные ключи: 'isPremiumCache' (Bool) + 'isPremiumCacheTimestamp' (Int, unix time) в NSUbiquitousKeyValueStore

## Question 4
FR-08: Graceful degradation если NSUbiquitousKeyValueStore недоступен. Для какого подмножества свойств использовать fallback на UserDefaults?

*Context:* Определяет надёжность при отсутствии entitlement: все ли свойства имеют fallback или только некритичные

**Options:**
- A) Все свойства: полный fallback на UserDefaults, NSUbiquitousKeyValueStore = опциональная оптимизация
- B) Только sync-свойства: currentThemeID, isPremiumCache → fallback; accounts, catalogs остаются локально
- C) Только isPremiumCache: critical для работы, fallback обязателен; остальное выбросить если нет iCloud

**Answer:**
Все свойства: полный fallback на UserDefaults, NSUbiquitousKeyValueStore = опциональная оптимизация

## Question 5
Accounts и catalogs хранят credentials (пароли → Keychain). Нужно ли синхронизировать сами accounts/catalogs через iCloud KVS?

*Context:* Определяет безопасность и согласованность: может ли пользователь иметь разные connected accounts на iPhone и iPad

**Options:**
- A) Синхронизировать через iCloud: accounts/catalogs (без паролей) → NSUbiquitousKeyValueStore, пароли остаются в Keychain (per-device)
- B) Только локально: accounts/catalogs остаются в UserDefaults, пользователь подключает отдельно на каждом устройстве
- C) Выдвинуть из iCloudSettingsStore: accounts/catalogs → отдельный CloudProviderStore с собственной логикой синхронизации

**Answer:**
Синхронизировать через iCloud: accounts/catalogs (без паролей) → NSUbiquitousKeyValueStore, пароли остаются в Keychain (per-device)

## Question 6
FR-07: Подписка на NSUbiquitousKeyValueStore.didChangeExternallyNotification. Как интегрировать с @Observable при получении внешних изменений?

*Context:* Определяет механизм синхронизации между устройствами: ручная публикация через ObservationRegistrar vs встроенная реактивность

**Options:**
- A) Explicit: в pathUpdateHandler обновить @Published свойства вручную, ObservationRegistrar автоматически уведомит подписчиков
- B) Использовать ObservationRegistrar.register(source:) для отслеживания NSUbiquitousKeyValueStore
- C) Простой подход: игнорировать FR-07, полагаться на то что приложение перезагружается при открытии из фона (практично для iCloud KVS)

**Answer:**
Explicit: в pathUpdateHandler обновить @Published свойства вручную, ObservationRegistrar автоматически уведомит подписчиков

## Question 7
FR-09: isPremium НИКОГДА не источник истины. Как проверяется isPremium в UI? Нужна ли интеграция с PremiumStateValidator или это отдельная логика?

*Context:* Определяет архитектурное взаимодействие: iCloudSettingsStore только кэш vs полная отдельная компонента PremiumStateValidator

**Options:**
- A) iCloudSettingsStore только кэш: UI использует PremiumStateValidator.isPremium напрямую, кэш игнорируется при offline с TTL
- B) Разделение ответственности: iCloudSettingsStore.isPremiumCache (с TTL) + PremiumStateValidator.validate() вызывается при online
- C) Не реализовывать сейчас: FR-09 в комментариях, isPremium в iCloudSettingsStore как простой boolean, PremiumStateValidator добавить в отдельной задаче

**Answer:**
Разделение ответственности: iCloudSettingsStore.isPremiumCache (с TTL) + PremiumStateValidator.validate() вызывается при online
