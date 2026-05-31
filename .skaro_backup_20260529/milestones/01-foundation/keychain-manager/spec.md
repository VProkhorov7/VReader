# Specification: keychain-manager (обновлено)

## Context
Инвариант #3 требует что все credentials хранятся только в Keychain. Gemini API ключ, OAuth токены, WebDAV пароли — только KeychainManager. Существующий KeychainManager.swift нужно проверить и дополнить до полной реализации.

## User Scenarios
1. **Пользователь вводит WebDAV пароль:** Сохраняется в Keychain, никогда не попадает в UserDefaults или логи.
2. **GeminiService запрашивает API ключ:** Получает из KeychainManager.shared, не из кода или Info.plist.
3. **OAuth токен истекает:** OAuthManager обновляет токен и сохраняет новый в Keychain.
4. **Переустановка приложения:** Пользователь переустанавливает приложение на том же устройстве с включённой iCloud Keychain синхронизацией — credentials автоматически восстанавливаются из облака.
5. **Widget extension обращается к credentials:** Widget использует тот же KeychainManager.shared с accessGroup = 'com.vreader.shared' для доступа к синхронизированным токенам.

## Functional Requirements
- FR-01: KeychainManager — singleton (shared), actor для thread safety; инициализируется с параметром accessGroup = 'com.vreader.shared' по умолчанию для поддержки App Group и Widget extension
- FR-02: func saveString(key: String, value: String) throws — сохранение строки в Keychain
- FR-03: func loadString(key: String) throws -> String — загрузка строки из Keychain
- FR-04: func deleteString(key: String) throws — удаление строки из Keychain
- FR-05: func saveData(key: String, data: Data) throws — сохранение Data (для токенов, сертификатов)
- FR-06: func loadData(key: String) throws -> Data — загрузка Data из Keychain
- FR-07: func delete(key: String) throws — удаление значения (String или Data) из Keychain по ключу
- FR-08: Определить enum KeychainKey с предопределёнными ключами: geminiAPIKey, googleDriveAccessToken, googleDriveRefreshToken, dropboxAccessToken, dropboxRefreshToken, oneDriveAccessToken, oneDriveRefreshToken, webDAVPassword(host: String), smbPassword(host: String)
- FR-09: Использовать kSecClassGenericPassword с kSecAttrService = bundle identifier
- FR-10: Ошибки через AppError с ErrorCode.auth(...) — как в текущем коде
- FR-11: func exists(key: String) -> Bool — проверка наличия значения без загрузки
- FR-12: func isSensitiveKey(key: KeychainKey) -> Bool — явный метод определения чувствительности ключа (возвращает true для всех credentials: tokens, passwords, API keys)
- FR-13: Поддержка iCloud Keychain синхронизации через kSecAttrSynchronizable = true для всех credentials — обеспечивает восстановление при переустановке приложения на том же устройстве

## Non-Functional Requirements
- NFR-01: Thread-safe доступ через actor-based реализацию
- NFR-02: Использовать kSecAttrAccessibleAfterFirstUnlock для работы в фоне; для локальных ключей (без синхронизации) — kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
- NFR-03: Поддержка App Group keychain для Widget extension через accessGroup = 'com.vreader.shared' по умолчанию; все credentials сохраняются с этим accessGroup для доступности из основного приложения и Widget
- NFR-04: Никаких значений credentials в логах — DiagnosticsService использует isSensitiveKey() для фильтрации и не должен получать доступ к значениям

## Boundaries (что НЕ входит)
- Не реализовывать биометрическую аутентификацию (Face ID, Touch ID)
- Не хранить в Keychain данные, не являющиеся credentials (книги, настройки, метаданные)
- Не реализовывать миграцию из UserDefaults в Keychain (пользователь должен переввести данные)
- Не реализовывать ручное управление iCloud Keychain синхронизацией — полагаться на системное поведение iOS

## Acceptance Criteria
- [ ] KeychainManager.shared существует, скомпилируется и инициализируется с accessGroup = 'com.vreader.shared'
- [ ] Методы saveString(), loadString(), deleteString() реализованы и работают без ошибок
- [ ] Методы saveData(), loadData(), delete() реализованы и работают без ошибок
- [ ] KeychainKey enum содержит все предопределённые ключи (geminiAPIKey, googleDrive*, dropbox*, oneDrive*, webDAVPassword, smbPassword)
- [ ] Все ошибки типизированы через AppError с ErrorCode.auth(...)
- [ ] Thread-safe реализация через actor
- [ ] Тест: сохранить строку через saveString(), загрузить через loadString(), проверить через exists(), удалить через deleteString() — без ошибок
- [ ] Тест: сохранить Data через saveData(), загрузить через loadData(), удалить через delete() — без ошибок
- [ ] Метод isSensitiveKey(key:) -> Bool реализован и возвращает true для всех credentials-ключей
- [ ] Все credentials сохраняются с kSecAttrSynchronizable = true для iCloud Keychain синхронизации
- [ ] DiagnosticsService не логирует значения credentials; использует isSensitiveKey() для фильтрации
- [ ] Нет логирования значений credentials при save/load операциях
- [ ] Widget extension может обращаться к credentials через тот же accessGroup = 'com.vreader.shared'

## Resolved Open Questions
- **Поддержка iCloud Keychain синхронизации:** Реализована через kSecAttrSynchronizable = true для всех credentials. При переустановке приложения на том же устройстве с включённой iCloud Keychain синхронизацией, credentials автоматически восстанавливаются из облака.
- **Поведение при переустановке приложения:** Явно обеспечивается через iCloud Keychain синхронизацию (FR-13). Пользователь должен включить iCloud Keychain в системных настройках для автоматического восстановления.

## Technical Notes
- KeychainManager использует один shared экземпляр с параметром accessGroup = 'com.vreader.shared' для единого доступа из основного приложения и Widget extension
- Методы разделены на saveString/loadString/deleteString для явности работы со строками и saveData/loadData/delete для работы с бинарными данными
- isSensitiveKey(key:) используется DiagnosticsService для фильтрации логов и должен вернуть true для всех ключей из KeychainKey enum
- Все операции с Keychain выполняются в actor-контексте для обеспечения thread safety