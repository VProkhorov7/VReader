# Tasks: keychain-manager

## Stage 1: Рефакторинг KeychainManager — новый публичный API

- [ ] Изменить `static let shared` на инициализацию с `accessGroup: "com.vreader.shared"` → `App/Vreader/Vreader/KeychainManager.swift`
- [ ] Переименовать `save(key: String, value: String)` → `saveString(key: String, value: String)` → `App/Vreader/Vreader/KeychainManager.swift`
- [ ] Переименовать `load(key: String) -> String` → `loadString(key: String) -> String` → `App/Vreader/Vreader/KeychainManager.swift`
- [ ] Переименовать `delete(key: String)` → `deleteString(key: String)` → `App/Vreader/Vreader/KeychainManager.swift`
- [ ] Переименовать `save(key: String, data: Data)` → `saveData(key: String, data: Data)` → `App/Vreader/Vreader/KeychainManager.swift`
- [ ] Переименовать `load(key: String) -> Data` → `loadData(key: String) -> Data` → `App/Vreader/Vreader/KeychainManager.swift`
- [ ] Добавить `deleteData(key: String) throws` (использует `"dat:"` префикс) → `App/Vreader/Vreader/KeychainManager.swift`
- [ ] Переименовать `save(key: KeychainKey, value: String)` → `saveString(key: KeychainKey, value: String)` → `App/Vreader/Vreader/KeychainManager.swift`
- [ ] Переименовать `load(key: KeychainKey) -> String` → `loadString(key: KeychainKey) -> String` → `App/Vreader/Vreader/KeychainManager.swift`
- [ ] Переименовать `delete(key: KeychainKey)` → `deleteString(key: KeychainKey)` → `App/Vreader/Vreader/KeychainManager.swift`
- [ ] Переименовать `save(key: KeychainKey, data: Data)` → `saveData(key: KeychainKey, data: Data)` → `App/Vreader/Vreader/KeychainManager.swift`
- [ ] Переименовать `load(key: KeychainKey) -> Data` → `loadData(key: KeychainKey) -> Data` → `App/Vreader/Vreader/KeychainManager.swift`
- [ ] Добавить `deleteData(key: KeychainKey) throws` → `App/Vreader/Vreader/KeychainManager.swift`
- [ ] Добавить `nonisolated func isSensitiveKey(_ key: KeychainKey) -> Bool` (всегда `true`) → `App/Vreader/Vreader/KeychainManager.swift`
- [ ] Убедиться, что `exists(key: String)` и `exists(key: KeychainKey)` не переименованы → `App/Vreader/Vreader/KeychainManager.swift`
- [ ] Проверить: `KeychainKey.isSynchronizable` — OAuth = `true`, остальные = `false` (конституция) → `App/Vreader/Vreader/KeychainManager.swift`
- [ ] Проверить: ни один метод не логирует значения credentials, только `account` и `OSStatus` → `App/Vreader/Vreader/KeychainManager.swift`

## Stage 2: Обновление вызывателей, DiagnosticsService и тестов

- [ ] Заменить все вызовы `KeychainManager.shared.save(key:value:)` на `saveString(key:value:)` → `App/Vreader/Vreader/iCloudSettingsStore.swift`
- [ ] Заменить все вызовы `KeychainManager.shared.load(key:)` (String) на `loadString(key:)` → `App/Vreader/Vreader/iCloudSettingsStore.swift`
- [ ] Заменить все вызовы `KeychainManager.shared.delete(key:)` на `deleteString(key:)` → `App/Vreader/Vreader/iCloudSettingsStore.swift`
- [ ] Проверить `WebDAVProvider.swift` через grep и обновить вызовы при наличии → `App/Vreader/Vreader/WebDAVProvider.swift`
- [ ] Проверить остальные файлы `App/Vreader/Vreader/*.swift` на старые вызовы KeychainManager и обновить
- [ ] Интегрировать `isSensitiveKey` в DiagnosticsService: вызов при фильтрации сообщений с именами ключей, сохранить `containsPII` как дополнительный слой → `App/Vreader/Vreader/DiagnosticsService.swift`
- [ ] Обновить `testSaveAndLoadString`: `save/load` → `saveString/loadString` → `App/Vreader/VreaderTests/VreaderTests.swift`
- [ ] Обновить `testSaveAndLoadData`: `save/load` → `saveData/loadData` → `App/Vreader/VreaderTests/VreaderTests.swift`
- [ ] Обновить `testDeleteString`: `save/delete` → `saveString/deleteString` → `App/Vreader/VreaderTests/VreaderTests.swift`
- [ ] Исправить `testDeleteData`: заменить `save/delete` на `saveData/deleteData`, проверить удаление через `loadData` + ошибку `.auth(.credentialsMissing)` → `App/Vreader/VreaderTests/VreaderTests.swift`
- [ ] Обновить `testLoadMissingKeyThrows`: `load` → `loadString` → `App/Vreader/VreaderTests/VreaderTests.swift`
- [ ] Обновить `testStringAndDataNoCollision`: `save/load` → `saveString/saveData/loadString/loadData` → `App/Vreader/VreaderTests/VreaderTests.swift`
- [ ] Обновить `testTypedOverloadDelegatesToRaw`: `save(key: KeychainKey)` → `saveString(key: KeychainKey)`, `load(key: String)` → `loadString(key: String)` → `App/Vreader/VreaderTests/VreaderTests.swift`
- [ ] Обновить `testOverwriteExistingKey`: `save/load` → `saveString/loadString` → `App/Vreader/VreaderTests/VreaderTests.swift`
- [ ] Добавить `testIsSensitiveKeyReturnsTrueForAllCases`: все 9 случаев `KeychainKey` → `true` → `App/Vreader/VreaderTests/VreaderTests.swift`
- [ ] Добавить `testDeleteDataRemovesDataEntry`: `saveData` → `deleteData` → `loadData` бросает `.auth(.credentialsMissing)` → `App/Vreader/VreaderTests/VreaderTests.swift`
- [ ] Добавить `testDeleteStringDoesNotAffectData`: `saveString + saveData` → `deleteString` → `loadData` по-прежнему возвращает данные → `App/Vreader/VreaderTests/VreaderTests.swift`
- [ ] Добавить `testSharedUsesAppGroupAccessGroup`: инициализация `KeychainManager.shared` не бросает исключений, accessGroup установлен → `App/Vreader/VreaderTests/VreaderTests.swift`