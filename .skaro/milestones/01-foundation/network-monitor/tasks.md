# Tasks: network-monitor

## Stage 1: Рефакторинг NetworkMonitor, регистрация в Environment, интеграционные тесты

### NetworkMonitor.swift — рефакторинг
- [ ] Изменить поле `monitor` с `let NWPathMonitor` на `private var monitor: NWPathMonitor?` (опциональная ссылка для поддержки stop/restart) → `App/Vreader/Vreader/NetworkMonitor.swift`
- [ ] Обновить `startMonitoring()`: вызвать `monitor?.cancel()` перед созданием нового `NWPathMonitor()`, сохранить в `monitor`, установить `pathUpdateHandler`, запустить через `monitor.start(queue:)` → `App/Vreader/Vreader/NetworkMonitor.swift`
- [ ] Обновить `stopMonitoring()`: вызвать `monitor?.cancel()`, установить `monitor = nil` → `App/Vreader/Vreader/NetworkMonitor.swift`
- [ ] Переписать определение `connectionType` через `path.availableInterfaces.first?.type` вместо `path.usesInterfaceType()` → `App/Vreader/Vreader/NetworkMonitor.swift`
- [ ] Изменить вычисление `isExpensive`: `connectionType == .cellular` вместо `path.isExpensive` → `App/Vreader/Vreader/NetworkMonitor.swift`
- [ ] Заменить `Task { @MainActor [weak self] in ... }` на `try? await MainActor.run(resultType: Void.self) { ... }` внутри `pathUpdateHandler` → `App/Vreader/Vreader/NetworkMonitor.swift`
- [ ] Добавить приватный метод `func logStateTransition(from oldValue: Bool, to newValue: Bool)` — вызывает `DiagnosticsService` через `Task { await DiagnosticsService.shared.log(...) }` с уровнем `.info`, категорией `.network`, сообщением `"network_online"` или `"network_offline"` → `App/Vreader/Vreader/NetworkMonitor.swift`
- [ ] В `pathUpdateHandler` сохранить старое значение `isOnline` до обновления и вызвать `logStateTransition(from:to:)` только если значение изменилось → `App/Vreader/Vreader/NetworkMonitor.swift`

### EnvironmentValues+NetworkMonitor.swift — новый файл
- [ ] Создать файл `App/Vreader/Vreader/EnvironmentValues+NetworkMonitor.swift`
- [ ] Объявить `private struct NetworkMonitorKey: EnvironmentKey` с `static let defaultValue = NetworkMonitor.shared` → `App/Vreader/Vreader/EnvironmentValues+NetworkMonitor.swift`
- [ ] Добавить расширение `extension EnvironmentValues` со свойством `var networkMonitor: NetworkMonitor { get set }` → `App/Vreader/Vreader/EnvironmentValues+NetworkMonitor.swift`

### VreaderApp.swift — регистрация в Environment
- [ ] В `VreaderApp.body` добавить `.environment(\.networkMonitor, NetworkMonitor.shared)` к `ContentView()` (рядом с существующим `.environment(\.appTheme, ...)`) → `App/Vreader/Vreader/VreaderApp.swift`

### DiagnosticsService.swift — добавление категории .network
- [ ] Добавить `case network` в перечисление `LogCategory` → `App/Vreader/Vreader/DiagnosticsService.swift`
- [ ] Если в usечённой части файла отсутствует метод с сигнатурой `func log(level:category:message:)` — добавить минимальный метод, создающий `LogEntry` и добавляющий в `buffer` с обрезкой до `bufferLimit`, плюс логирование через `os.Logger` → `App/Vreader/Vreader/DiagnosticsService.swift`
- [ ] Проверить наличие exhaustive `switch` по `LogCategory` в DiagnosticsService — при необходимости добавить обработку `.network` → `App/Vreader/Vreader/DiagnosticsService.swift`

### VreaderUITests.swift — интеграционные тесты
- [ ] Добавить тест `testNetworkMonitorInitialized()`: запустить `XCUIApplication()`, вызвать `app.launch()`, проверить `app.state == .runningForeground` — подтверждает, что приложение стартует без краша с зарегистрированным `NetworkMonitor` в Environment → `App/Vreader/VreaderUITests/VreaderUITests.swift`
- [ ] Добавить тест `testNetworkMonitorEnvironmentRegistered()`: запустить приложение, сделать скриншот стартового экрана, прикрепить как `XCTAttachment` с именем `"NetworkMonitor Environment"` → `App/Vreader/VreaderUITests/VreaderUITests.swift`
- [ ] Убедиться, что существующий `testLaunch` в `VreaderUITestsLaunchTests.swift` не требует изменений (уже делает скриншот) → `App/Vreader/VreaderUITests/VreaderUITestsLaunchTests.swift`