# Clarifications: 01-foundation::keychain-manager

## Question 1
Спецификация требует 'ошибки через VReaderError с ErrorCode.authentication', но существующий код использует AppError. Какой тип ошибки использовать в KeychainManager?

*Context:* Выбор типа ошибки влияет на интеграцию с остальной системой обработки ошибок и аналитикой

**Options:**
- A) Использовать AppError с ErrorCode.auth(...) — как в текущем коде
- B) Создать отдельный тип VReaderError и использовать его в KeychainManager
- C) Использовать AppError, но переименовать ErrorCode.auth в ErrorCode.authentication для соответствия спеке

**Answer:**
Использовать AppError с ErrorCode.auth(...) — как в текущем коде

## Question 2
Код использует префиксы 'str:' и 'dat:' для разделения String и Data в одном ключе (account = 'str:mykey' vs 'dat:mykey'). Нужна ли эта логика, или String и Data всегда используются в разных ключах?

*Context:* Если ключи всегда разные, эта логика усложняет код без пользы. Если одинаковые ключи могут хранить оба типа, это необходимо

**Options:**
- A) Оставить префиксы — одинаковый ключ может хранить и String, и Data одновременно
- B) Удалить префиксы — гарантировать, что один ключ используется только для одного типа
- C) Разделить методы на loadString()/loadData() и delete()/deleteString() для явности

**Answer:**
Разделить методы на loadString()/loadData() и delete()/deleteString() для явности

## Question 3
Спецификация упоминает (Open Question) поддержку App Group keychain для Widget extension (NFR-03). Как должен инициализироваться KeychainManager для Widget: отдельный экземпляр с accessGroup или общий shared?

*Context:* Widget и App используют разные процессы. Shared container для Keychain требует правильного accessGroup, иначе Widget не сможет читать credentials

**Options:**
- A) Создать второй singleton: KeychainManager.widgetShared(accessGroup:) для Widget
- B) Использовать один shared с параметром accessGroup = 'com.vreader.shared' по умолчанию
- C) Widget должен иметь свой отдельный Keychain (accessGroup = nil), без синхронизации с App

**Answer:**
Использовать один shared с параметром accessGroup = 'com.vreader.shared' по умолчанию

## Question 4
При переустановке приложения (спец Open Question #2): нужно ли явно обрабатывать восстановление Keychain, или полагаться на то, что iOS автоматически сохраняет Keychain для того же Bundle ID?

*Context:* Это влияет на логику инициализации приложения и обработку случая, когда Keychain пуст при первом запуске переустановленного приложения

**Options:**
- A) Полагаться на iOS — Keychain автоматически сохраняется при переустановке того же Bundle ID (iOS 13+)
- B) Реализовать явное восстановление — например, iCloud Keychain синхронизация как backup
- C) Очищать Keychain при каждой переустановке — требовать повторного входа пользователя

**Answer:**
Реализовать явное восстановление — например, iCloud Keychain синхронизация как backup

## Question 5
Код имеет перегруженные методы load(key: KeychainKey) -> String и load(key: KeychainKey) -> Data, где тип результата определяется типом переменной-приёмника. Нужно ли переименовать на loadString() и loadData() для явности, или текущий подход приемлем?

*Context:* Неявная типизация может привести к ошибкам на этапе компиляции. Явные имена методов улучшают читаемость и безопасность типов

**Options:**
- A) Оставить перегрузку — полагаться на Swift type inference
- B) Переименовать на loadString(key:) и loadData(key:) для явности
- C) Использовать generic метод load<T>(key:) -> T с ограничением T: Decodable

**Answer:**
Переименовать на loadString(key:) и loadData(key:) для явности

## Question 6
Спецификация требует 'никаких значений credentials в логах' (FR-11). Текущий код проверяет PII по ключевым словам ('token', 'password', 'key'). Достаточно ли этой эвристики для KeychainManager, или нужна явная whitelist/blacklist ключей?

*Context:* Простая эвристика может пропустить новые ключи или логировать false positives. Явная whitelist/blacklist безопаснее, но требует обновления при добавлении новых ключей

**Options:**
- A) Использовать существующую эвристику DiagnosticsService (содержит 'token'/'password'/'key')
- B) Создать явный метод isSensitiveKey(key: KeychainKey) -> Bool в KeychainManager
- C) Никогда не логировать имена ключей KeychainKey, только статус операций (успех/ошибка)

**Answer:**
Создать явный метод isSensitiveKey(key: KeychainKey) -> Bool в KeychainManager
