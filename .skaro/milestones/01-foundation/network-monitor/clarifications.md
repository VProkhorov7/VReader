# Clarifications: 01-foundation::network-monitor

## Question 1
При инициализации NetworkMonitor isOnline инициализируется как false. Должен ли он синхронно определить реальное состояние сети в init(), или отложить инициализацию до первого обновления от NWPathMonitor?

*Context:* Это влияет на скорость первого отображения UI и может вызвать неправильное отображение offline banner при старте приложения если устройство онлайн.

**Options:**
- A) Синхронно инициализировать состояние в init() через path.status перед monitor.start()
- B) Отложить инициализацию до первого pathUpdateHandler callback (текущее поведение)
- C) Инициализировать через асинхронный Task в init() без await

**Answer:**
Отложить инициализацию до первого pathUpdateHandler callback (текущее поведение)

## Question 2
Если вызвать stopMonitoring() потом startMonitoring(), должен ли код переиспользовать существующий NWPathMonitor или создать новый экземпляр?

*Context:* Текущий код переиспользует monitor после cancel(), что может привести к ошибкам. NWPathMonitor может не поддерживать повторный start после cancel().

**Options:**
- A) Создавать новый NWPathMonitor() при каждом startMonitoring()
- B) Переиспользовать существующий (текущее поведение), но гарантировать это работает
- C) Запретить повторный startMonitoring() после stopMonitoring() - вызвать fatalError

**Answer:**
Создавать новый NWPathMonitor() при каждом startMonitoring()

## Question 3
Нужно ли NetworkMonitor логировать события изменения состояния сети (онлайн/оффлайн) в DiagnosticsService для отладки и аналитики?

*Context:* Open question в спецификации. Это помогает отладить проблемы с синхронизацией и понять когда приложение теряло сеть.

**Options:**
- A) Логировать все события через DiagnosticsService.log() с timestamp и старое/новое состояние
- B) Логировать только переходы (false→true, true→false), не все обновления
- C) Не логировать, это вне области NetworkMonitor

**Answer:**
Логировать только переходы (false→true, true→false), не все обновления

## Question 4
Как должны выглядеть unit-тесты для NetworkMonitor в VreaderTests? Нужно ли мокировать NWPathMonitor или использовать реальную сеть?

*Context:* Open question в спецификации. Мокирование сложно, но реальная сеть делает тесты хрупкими. Это влияет на достижимость тестового покрытия.

**Options:**
- A) Мокировать NWPathMonitor через protokol/injection, создать MockNetworkMonitor для тестов
- B) Использовать реальную NWPathMonitor и симулировать offline отключением Wi-Fi в CI
- C) Не писать unit-тесты, только интеграционные тесты в VreaderUITests

**Answer:**
Не писать unit-тесты, только интеграционные тесты в VreaderUITests

## Question 5
Как должен быть зарегистрирован NetworkMonitor в VreaderApp для доступа из всех вьюх? Через .environment(EnvironmentKey) или напрямую использовать NetworkMonitor.shared?

*Context:* FR-09 говорит о регистрации через .environment(), но текущий код использует singleton. Это влияет на тестируемость и внедрение зависимостей.

**Options:**
- A) Создать NetworkMonitorKey: EnvironmentKey и передавать через .environment() в ContentView
- B) Напрямую использовать NetworkMonitor.shared без @Environment (текущее поведение)
- C) Создать @Environment wrapper который внутри использует NetworkMonitor.shared

**Answer:**
Создать NetworkMonitorKey: EnvironmentKey и передавать через .environment() в ContentView

## Question 6
Должен ли NetworkMonitor различать между полностью offline и 'limited connectivity' (captive portal, слабый сигнал)? Или path.status == .satisfied достаточно?

*Context:* Это влияет на поведение AI сервисов и облачных операций. Limited connectivity может требовать других обработок ошибок чем полный offline.

**Options:**
- A) Различать через path.status (unsatisfied vs requiresConnection vs satisfied)
- B) Использовать только path.status == .satisfied, сложные случаи обрабатывать на уровне сервисов
- C) Добавить var isLimited: Bool для captive portal detection

**Answer:**
Использовать только path.status == .satisfied, сложные случаи обрабатывать на уровне сервисов

## Question 7
Является ли подход с Task { @MainActor } внутри pathUpdateHandler (который выполняется на background queue) безопасным для @Observable синхронизации, или нужна другая стратегия?

*Context:* Это критично для гарантии thread-safety обновлений @Observable свойств и предотвращения race conditions в UI.

**Options:**
- A) Task { @MainActor } достаточно, обновления будут синхронизированы правильно
- B) Использовать DispatchQueue.main.async вместо Task { @MainActor }
- C) Использовать MainActor.run(resultType:body:) для синхронных обновлений

**Answer:**
Использовать MainActor.run(resultType:body:) для синхронных обновлений
