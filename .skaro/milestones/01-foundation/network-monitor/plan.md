## plan.md

## Stage 1: Рефакторинг NetworkMonitor, регистрация в Environment, интеграционные тесты

**Goal:** Привести NetworkMonitor в полное соответствие со спецификацией: пересоздание NWPathMonitor при каждом startMonitoring(), определение connectionType через path.availableInterfaces, isExpensive через connectionType, переход на MainActor.run(resultType:body:), логирование переходов состояния в DiagnosticsService, регистрация через EnvironmentKey, интеграционные тесты.

**Depends on:** нет

**Inputs:**
- `App/Vreader/Vreader/NetworkMonitor.swift` (существующий)
- `App/Vreader/Vreader/VreaderApp.swift` (существующий)
- `App/Vreader/Vreader/DiagnosticsService.swift` (существующий, усечённый в листинге)
- `App/Vreader/VreaderUITests/VreaderUITests.swift` (существующий)
- Спецификация `network-monitor`, Architecture, Constitution

**Outputs:**
1. `App/Vreader/Vreader/NetworkMonitor.swift` — полный рефакторинг согласно FR-01…FR-10
2. `App/Vreader/Vreader/EnvironmentValues+NetworkMonitor.swift` — новый файл: `NetworkMonitorKey: EnvironmentKey` + расширение `EnvironmentValues`
3. `App/Vreader/Vreader/VreaderApp.swift` — добавить `.environment(\.networkMonitor, NetworkMonitor.shared)`
4. `App/Vreader/Vreader/DiagnosticsService.swift` — добавить case `.network` в `LogCategory`; добавить метод `func log(level:category:message:)` если отсутствует в усечённой части
5. `App/Vreader/VreaderUITests/VreaderUITests.swift` — интеграционные тесты: запуск приложения, проверка инициализации монитора, скриншот

**DoD:**
- [ ] `NetworkMonitor` является `@Observable @MainActor final class` с `static let shared`
- [ ] `isOnline` инициализируется как `false`; реальное значение определяется при первом `pathUpdateHandler` callback
- [ ] `startMonitoring()` создаёт `NWPathMonitor()` при каждом вызове; старый монитор останавливается через `monitor.cancel()` перед заменой
- [ ] `stopMonitoring()` вызывает `monitor.cancel()` и обнуляет `monitor` (опциональная ссылка)
- [ ] `connectionType` определяется через `path.availableInterfaces.first?.type`: `.wifi → .wifi`, `.cellular → .cellular`, `.wiredEthernet → .wiredEthernet`, иное → `.unknown`
- [ ] `isExpensive` вычисляется как `connectionType == .cellular` (не `path.isExpensive`)
- [ ] Все мутации `isOnline`, `connectionType`, `isExpensive` выполняются через `MainActor.run(resultType: Void.self) { ... }` внутри `pathUpdateHandler`
- [ ] `logStateTransition(from:to:)` вызывается только при изменении значения `isOnline`; логирует `"network_online"` или `"network_offline"` в `DiagnosticsService` через `Task { await DiagnosticsService.shared.log(...) }`
- [ ] `LogCategory` содержит case `.network` в `DiagnosticsService.swift`
- [ ] `NetworkMonitorKey: EnvironmentKey` создан в `EnvironmentValues+NetworkMonitor.swift`; `defaultValue = NetworkMonitor.shared`
- [ ] `EnvironmentValues` расширен свойством `networkMonitor: NetworkMonitor`
- [ ] `VreaderApp.body` содержит `.environment(\.networkMonitor, NetworkMonitor.shared)`
- [ ] UI-тест `testNetworkMonitorInitialized` запускает приложение и проходит без краша
- [ ] UI-тест `testLaunch` (существующий) по-прежнему делает скриншот и прикладывает его
- [ ] `check_refs.py` не выдаёт новых ошибок

**Risks:**
- DiagnosticsService.swift в листинге усечён — реальная сигнатура метода `log(...)` неизвестна. Если метод принимает `LogEntry` напрямую — создать через `LogEntry(timestamp:level:category:message:)`; если принимает параметры отдельно — вызвать напрямую. В крайнем случае добавить минимальный convenience-метод `func logEvent(_ message: String, level: LogLevel, category: LogCategory)`.
- `NWPathMonitor` может не поддерживаться в симуляторе для всех типов интерфейсов — `connectionType` может вернуть `.unknown`; это не ошибка, тест не должен проверять конкретное значение `connectionType`.
- Добавление `.network` в `LogCategory` — минимальное изменение; не нарушает существующие switch-операторы (если они не exhaustive без `default`). При наличии exhaustive switch в DiagnosticsService — добавить обработку нового case.

## Verify

- name: Сборка проекта (iOS Simulator)
  command: xcodebuild build -project App/Vreader/Vreader.xcodeproj -scheme Vreader -destination "platform=iOS Simulator,name=iPhone 16" -quiet 2>&1 | tail -10

- name: Проверка check_refs.py
  command: python3 check_refs.py

- name: Запуск UI-тестов (интеграция NetworkMonitor)
  command: xcodebuild test -project App/Vreader/Vreader.xcodeproj -scheme Vreader -destination "platform=iOS Simulator,name=iPhone 16" -only-testing:VreaderUITests/VreaderUITests/testNetworkMonitorInitialized -quiet 2>&1 | tail -20

- name: Запуск Launch-теста (скриншот при старте)
  command: xcodebuild test -project App/Vreader/Vreader.xcodeproj -scheme Vreader -destination "platform=iOS Simulator,name=iPhone 16" -only-testing:VreaderUITests/VreaderUITestsLaunchTests/testLaunch -quiet 2>&1 | tail -20

- name: Поиск запрещённых паттернов (coverData, isPremium в CloudKit)
  command: grep -rn "coverData:" App/Vreader/Vreader/ --include="*.swift" | grep -v "//"; grep -rn "isPremium" App/Vreader/Vreader/ --include="*.swift" | grep -v "//" | grep -i "cloudkit\|ckrecord" || echo "OK"