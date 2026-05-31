# Specification: network-monitor

## Context
Многие сервисы (GeminiService, CloudProviders, MetadataFetcher) требуют сети. При отсутствии сети они должны немедленно возвращать .offline ошибку, а UI должен показывать offline banner. NetworkMonitor — единственный источник истины о состоянии сети.

## User Scenarios
1. **Устройство уходит в оффлайн:** NetworkMonitor.isOnline становится false, TranslationPanel показывает offline banner.
2. **Сеть восстанавливается:** isOnline становится true, PendingChangesQueue начинает синхронизацию.
3. **GeminiService вызывается без сети:** Проверяет NetworkMonitor.shared.isOnline, немедленно возвращает VReaderError.offline().

## Functional Requirements
- FR-01: NetworkMonitor — @Observable singleton (shared), @MainActor
- FR-02: var isOnline: Bool — текущее состояние сети, инициализируется как false до первого pathUpdateHandler callback
- FR-03: var connectionType: ConnectionType — enum: wifi, cellular, wiredEthernet, unknown; определяется на основе path.availableInterfaces
- FR-04: Использовать NWPathMonitor для отслеживания изменений сетевого интерфейса
- FR-05: Обновления публиковать на main thread через MainActor.run(resultType:body:) внутри pathUpdateHandler
- FR-06: func startMonitoring() и func stopMonitoring() для управления жизненным циклом; startMonitoring() создаёт новый NWPathMonitor() при каждом вызове
- FR-07: Автоматический старт при инициализации (init вызывает startMonitoring())
- FR-08: var isExpensive: Bool — true если cellular соединение (для ограничения фоновых загрузок); основана на connectionType == .cellular
- FR-09: Зарегистрировать в VreaderApp через NetworkMonitorKey: EnvironmentKey и .environment(\.networkMonitor, NetworkMonitor.shared)
- FR-10: func logStateTransition(from:to:) — логирование переходов (false→true, true→false) в DiagnosticsService; вызывается только при изменении значения isOnline

## Non-Functional Requirements
- NFR-01: Минимальная задержка обнаружения изменений сети (< 1 секунда)
- NFR-02: Не создавать утечек памяти при многократном start/stop; старый NWPathMonitor корректно останавливается перед созданием нового
- NFR-03: Thread-safe доступ к @Observable свойствам; все мутации выполняются на main thread
- NFR-04: Логирование только переходов состояния, не всех обновлений от NWPathMonitor (для минимизации шума в DiagnosticsService)

## Design Details

### Инициализация и жизненный цикл
- При инициализации NetworkMonitor isOnline устанавливается в false
- startMonitoring() создаёт новый экземпляр NWPathMonitor (не переиспользует существующий)
- pathUpdateHandler вызывается при изменении path; реальное состояние сети определяется при первом callback
- stopMonitoring() останавливает текущий монитор и очищает ссылку
- Повторный вызов startMonitoring() после stopMonitoring() создаёт новый NWPathMonitor

### Определение состояния сети
- isOnline = true только когда path.status == .satisfied (не рассматриваются limited connectivity, captive portal, слабый сигнал)
- Сложные случаи (ограниченная связь) обрабатываются на уровне конкретных сервисов (например, GeminiService может проверить HTTP-статус 503)
- connectionType определяется по path.availableInterfaces[0].type:
  - .wifi → .wifi
  - .cellular → .cellular
  - .wiredEthernet → .wiredEthernet
  - иное → .unknown

### Thread-safety
- pathUpdateHandler выполняется на background queue (NWPathMonitor)
- Все обновления isOnline, connectionType выполняются через MainActor.run(resultType: Void.self) { ... }
- Гарантируется, что @Observable синхронизация происходит на main thread

### Логирование
- При переходе isOnline: false → true вызывается DiagnosticsService.log(event: "network_online")
- При переходе isOnline: true → false вызывается DiagnosticsService.log(event: "network_offline")
- logStateTransition(from:to:) вызывается только из pathUpdateHandler, если значение isOnline изменилось
- Промежуточные обновления (например, смена типа соединения при isOnline = true) не логируются

### Environment регистрация
- Создан NetworkMonitorKey: EnvironmentKey с defaultValue = NetworkMonitor.shared
- В VreaderApp (ContentView) добавлено .environment(\.networkMonitor, NetworkMonitor.shared)
- Вьюхи получают монитор через @Environment(\.networkMonitor) var networkMonitor

## Boundaries (что НЕ входит)
- Не реализовывать логику retry при восстановлении сети (это BackgroundSyncTask)
- Не показывать UI баннеры (это задача View компонентов)
- Не тестировать конкретные endpoints (только системный статус сети)
- Не различать между полностью offline и limited connectivity (captive portal, слабый сигнал)
- Не сохранять историю всех изменений сети; логировать только переходы состояния

## Testing Strategy
- Не писать unit-тесты в VreaderTests (NWPathMonitor сложно мокировать)
- Интеграционные тесты в VreaderUITests:
  - Запуск приложения и проверка, что NetworkMonitor.shared инициализирован
  - Скриншоты при старте (проверка, что environment зарегистрирован)
  - Может использоваться Network Link Conditioner для симуляции offline (если доступен на CI)

## Acceptance Criteria
- [ ] NetworkMonitor.shared существует и является @Observable @MainActor singleton
- [ ] isOnline инициализируется как false, определяется при первом pathUpdateHandler callback
- [ ] connectionType и isExpensive определены и корректно отражают текущее соединение
- [ ] Обновления isOnline приходят на main thread (через MainActor.run)
- [ ] startMonitoring() создаёт новый NWPathMonitor при каждом вызове
- [ ] stopMonitoring() корректно останавливает монитор, нет утечек памяти
- [ ] logStateTransition логирует только переходы false→true и true→false в DiagnosticsService
- [ ] NetworkMonitorKey зарегистрирован в Environment, доступен как @Environment(\.networkMonitor)
- [ ] VreaderApp передаёт NetworkMonitor.shared через .environment()
- [ ] Интеграционные тесты в VreaderUITests подтверждают инициализацию и регистрацию

## Resolved Questions

**Q1: Инициализация isOnline в init() vs первый pathUpdateHandler callback**
- ✅ Отложить инициализацию до первого pathUpdateHandler callback; isOnline стартует как false

**Q2: Переиспользование NWPathMonitor при повторном startMonitoring()**
- ✅ Создавать новый NWPathMonitor() при каждом startMonitoring()

**Q3: Логирование переходов в DiagnosticsService**
- ✅ Логировать только переходы (false→true, true→false), не все обновления; добавлен logStateTransition(from:to:)

**Q4: Unit-тесты vs интеграционные тесты**
- ✅ Не писать unit-тесты; использовать интеграционные тесты в VreaderUITests

**Q5: Регистрация в VreaderApp**
- ✅ Создать NetworkMonitorKey: EnvironmentKey и передавать через .environment(\.networkMonitor)

**Q6: Limited connectivity vs полный offline**
- ✅ Использовать только path.status == .satisfied; сложные случаи обрабатывать на уровне сервисов

**Q7: Thread-safety для @Observable**
- ✅ Использовать MainActor.run(resultType:body:) для синхронных обновлений из pathUpdateHandler