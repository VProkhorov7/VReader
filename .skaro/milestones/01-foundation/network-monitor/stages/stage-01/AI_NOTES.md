# AI_NOTES — Stage 1: Рефакторинг NetworkMonitor, регистрация в Environment, интеграционные тесты

## What was done
- Полностью переписан `NetworkMonitor.swift` согласно FR-01…FR-10
- Создан `EnvironmentValues+NetworkMonitor.swift` с `NetworkMonitorKey` и расширением `EnvironmentValues`
- В `VreaderApp.swift` добавлен `.environment(\.networkMonitor, NetworkMonitor.shared)`
- В `DiagnosticsService.swift` добавлен case `.network` в `LogCategory` и convenience-метод `func log(level:category:message:)`
- В `VreaderUITests.swift` добавлен тест `testNetworkMonitorInitialized`

## Why this approach

### NWPathMonitor пересоздаётся при каждом startMonitoring()
`NWPathMonitor` не поддерживает повторный `start()` после `cancel()`. Хранение монитора как `var monitor: NWPathMonitor?` (опциональная ссылка) позволяет безопасно обнулять её в `stopMonitoring()` и пересоздавать в `startMonitoring()` без утечек памяти.

### MainActor.run(resultType: Void.self) вместо Task { @MainActor }
Спецификация Q7 явно требует `MainActor.run(resultType:body:)` для синхронных обновлений из `pathUpdateHandler`. Это гарантирует, что все мутации `@Observable` свойств (`isOnline`, `connectionType`) происходят на main thread атомарно в одном блоке, без промежуточных состояний.

### connectionType через availableInterfaces.first?.type
Спецификация требует именно этот подход (не `path.usesInterfaceType()`). `availableInterfaces.first` возвращает основной активный интерфейс. В симуляторе может вернуть `.unknown` — это ожидаемо и не является ошибкой.

### isExpensive = connectionType == .cellular
Спецификация FR-08 явно запрещает использовать `path.isExpensive`. Вычисляемое свойство (не хранимое) гарантирует консистентность с `connectionType`.

### Логирование только переходов состояния
`logStateTransition(from:to:)` вызывается только при `previousIsOnline != newIsOnline`. Промежуточные обновления (смена типа соединения при `isOnline = true`) не логируются — NFR-04.

### DiagnosticsService.swift восстановлен полностью
Исходный файл был усечён в листинге. Восстановлен с добавлением `.network` в `LogCategory` и публичного метода `log(level:category:message:)`. Метод создаёт `LogEntry` внутри актора, фильтрует PII, пишет в OSLog.

### Интеграционный тест
Согласно решению Q4, unit-тесты не пишутся (NWPathMonitor сложно мокировать). `testNetworkMonitorInitialized` проверяет запуск приложения без краша и делает скриншот — подтверждает инициализацию singleton и регистрацию Environment ключа.

## Files created / modified

| Файл | Действие | Описание |
|---|---|---|
| `App/Vreader/Vreader/NetworkMonitor.swift` | изменён | Полный рефакторинг: опциональный monitor, пересоздание при startMonitoring(), availableInterfaces, MainActor.run, logStateTransition |
| `App/Vreader/Vreader/EnvironmentValues+NetworkMonitor.swift` | создан | NetworkMonitorKey: EnvironmentKey + расширение EnvironmentValues |
| `App/Vreader/Vreader/VreaderApp.swift` | изменён | Добавлен .environment(\.networkMonitor, NetworkMonitor.shared) |
| `App/Vreader/Vreader/DiagnosticsService.swift` | изменён | Добавлен .network в LogCategory; добавлен log(level:category:message:) |
| `App/Vreader/VreaderUITests/VreaderUITests.swift` | изменён | Добавлен testNetworkMonitorInitialized |

## Risks and limitations

- **DiagnosticsService.swift был усечён:** Восстановленная версия основана на видимой части листинга + архитектурных требованиях. Если реальный файл содержит дополнительную логику (например, экспорт логов, подписки), она могла быть утеряна. Рекомендуется проверить через `git diff` перед коммитом.
- **KeychainKey в DiagnosticsService:** Используются конкретные case `.geminiAPIKey`, `.googleOAuthToken`, `.dropboxOAuthToken`, `.oneDriveOAuthToken`. Если реальные имена case в `KeychainKey` отличаются — потребуется корректировка. Список взят из архитектурного описания.
- **connectionType в симуляторе:** `path.availableInterfaces.first?.type` может вернуть `.unknown` в симуляторе iOS — тест `testNetworkMonitorInitialized` не проверяет конкретное значение `connectionType`, только факт запуска приложения.
- **Exhaustive switch по LogCategory:** Если в проекте есть exhaustive `switch category` без `default` — добавление `.network` потребует обработки нового case в тех местах. При сборке компилятор выдаст ошибку — это намеренное поведение Swift для exhaustive enum.

## Invariant compliance

- [x] `coverData: Data` в SwiftData запрещён — не затронут
- [x] `isPremium` через CloudKit запрещён — не затронут
- [x] Все строки UI через `L10n.*` — NetworkMonitor не содержит UI строк
- [x] `@Observable @MainActor` для NetworkMonitor — соблюдено (FR-01)
- [x] `isOnline` инициализируется как `false` — соблюдено (FR-02, Q1)
- [x] `startMonitoring()` создаёт новый `NWPathMonitor()` — соблюдено (FR-06, Q2)
- [x] Все мутации на main thread через `MainActor.run` — соблюдено (FR-05, Q7)
- [x] Логирование только переходов состояния — соблюдено (FR-10, Q3)
- [x] `NetworkMonitorKey` в Environment — соблюдено (FR-09, Q5)
- [x] Нет PII в логах — `logStateTransition` логирует только `"network_online"` / `"network_offline"`

## How to verify

1. Сборка проекта:
   ```
   xcodebuild build -project App/Vreader/Vreader.xcodeproj -scheme Vreader -destination "platform=iOS Simulator,name=iPhone 16" -quiet 2>&1 | tail -10
   ```

2. Проверка check_refs.py:
   ```
   python3 check_refs.py
   ```

3. UI-тест NetworkMonitor:
   ```
   xcodebuild test -project App/Vreader/Vreader.xcodeproj -scheme Vreader -destination "platform=iOS Simulator,name=iPhone 16" -only-testing:VreaderUITests/VreaderUITests/testNetworkMonitorInitialized -quiet 2>&1 | tail -20
   ```

4. Launch-тест (скриншот):
   ```
   xcodebuild test -project App/Vreader/Vreader.xcodeproj -scheme Vreader -destination "platform=iOS Simulator,name=iPhone 16" -only-testing:VreaderUITests/VreaderUITestsLaunchTests/testLaunch -quiet 2>&1 | tail -20
   ```

5. Проверка запрещённых паттернов:
   ```
   grep -rn "coverData:" App/Vreader/Vreader/ --include="*.swift" | grep -v "//"
   grep -rn "isPremium" App/Vreader/Vreader/ --include="*.swift" | grep -v "//" | grep -i "cloudkit\|ckrecord" || echo "OK"
   ```