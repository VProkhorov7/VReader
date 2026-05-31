## plan.md

---

## Stage 1: Рефакторинг KeychainManager — новый публичный API

**Goal:** Полностью обновить `KeychainManager.swift`: singleton с App Group accessGroup по умолчанию, явные именованные методы `saveString/loadString/deleteString/saveData/loadData/deleteData`, новый метод `isSensitiveKey`. Конституционный инвариант `isSynchronizable` (OAuth = true, локальные ключи = false) сохраняется без изменений.

**Depends on:** нет

**Inputs:**
- `App/Vreader/Vreader/KeychainManager.swift` (существующий)
- `App/Vreader/Vreader/AppError.swift`
- `App/Vreader/Vreader/L10n.swift`
- Конституция (раздел Keychain), Спецификация FR-01…FR-13, NFR-01…NFR-04
- Ответы на Clarifications Q1–Q6

**Outputs:**
- `App/Vreader/Vreader/KeychainManager.swift` (полная перезапись публичного API)

**DoD:**
- [ ] `KeychainManager.shared` инициализируется с `accessGroup: "com.vreader.shared"` — FR-01, NFR-03
- [ ] Публичные методы для String-ключей: `saveString(key: String, value: String)`, `loadString(key: String) -> String`, `deleteString(key: String)` — FR-02, FR-03, FR-04
- [ ] Публичные методы для Data-ключей: `saveData(key: String, data: Data)`, `loadData(key: String) -> Data`, `deleteData(key: String)` — FR-05, FR-06, FR-07
- [ ] Все шесть методов выше продублированы с перегрузкой `key: KeychainKey` — FR-08
- [ ] `exists(key: String) -> Bool` и `exists(key: KeychainKey) -> Bool` — FR-11
- [ ] `nonisolated func isSensitiveKey(_ key: KeychainKey) -> Bool` возвращает `true` для всех случаев — FR-12
- [ ] `KeychainKey.isSynchronizable`: OAuth-токены `true`, `geminiAPIKey/webDAVPassword/smbPassword` `false` — конституция
- [ ] `KeychainKey.accessibility`: синхронизируемые → `kSecAttrAccessibleAfterFirstUnlock`, локальные → `kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly` — NFR-02
- [ ] Приватные методы `performSave/performLoad/performDelete/performExists` не меняют сигнатуры и логику
- [ ] Ни один приватный метод не логирует значения (`kSecValueData`), только `account` и `OSStatus` — NFR-04
- [ ] Файл компилируется изолированно (можно проверить через `swiftc -typecheck`)

**Risks:**
- Переименование методов сломает всех вызывателей — это ожидаемо и исправляется в Stage 2
- `deleteData(key:)` — новый метод, которого не было раньше; тест в Stage 2 должен проверить корректность удаления `"dat:"` префикса
- Существующий тест `testDeleteData` имеет скрытый баг: вызывал `delete(key:)` с `"str:"` префиксом вместо `"dat:"` — исправить в Stage 2

---

## Stage 2: Обновление вызывателей, DiagnosticsService и тестов

**Goal:** Обновить все файлы, вызывающие переименованные методы KeychainManager. Интегрировать `isSensitiveKey` в DiagnosticsService. Обновить и расширить тесты `KeychainManagerTests`.

**Depends on:** Stage 1

**Inputs:**
- `App/Vreader/Vreader/KeychainManager.swift` (из Stage 1, новый API)
- `App/Vreader/Vreader/iCloudSettingsStore.swift`
- `App/Vreader/Vreader/DiagnosticsService.swift`
- `App/Vreader/Vreader/WebDAVProvider.swift` (проверить вызовы)
- `App/Vreader/VreaderTests/VreaderTests.swift`

**Outputs:**
- `App/Vreader/Vreader/iCloudSettingsStore.swift` (обновлённые вызовы)
- `App/Vreader/Vreader/DiagnosticsService.swift` (интеграция `isSensitiveKey`)
- `App/Vreader/Vreader/WebDAVProvider.swift` (обновлённые вызовы, если есть)
- `App/Vreader/VreaderTests/VreaderTests.swift` (обновлённые + новые тесты)

**DoD:**

*iCloudSettingsStore.swift:*
- [ ] `KeychainManager.shared.save(key:value:)` → `saveString(key:value:)` во всех вхождениях
- [ ] `KeychainManager.shared.load(key:)` (String result) → `loadString(key:)`
- [ ] `KeychainManager.shared.delete(key:)` → `deleteString(key:)` во всех вхождениях
- [ ] Файл компилируется без ошибок

*DiagnosticsService.swift:*
- [ ] Добавлен `nonisolated` вспомогательный метод или расширение, использующее `KeychainManager.isSensitiveKey` при фильтрации сообщений, связанных с ключами — AC «DiagnosticsService использует isSensitiveKey() для фильтрации»
- [ ] Существующий `containsPII` сохранён как дополнительный слой фильтрации
- [ ] Файл компилируется без ошибок

*WebDAVProvider.swift (и прочие вызыватели):*
- [ ] Проверены все файлы проекта на вхождения `.save(key:`, `.load(key:`, `.delete(key:`
- [ ] Все найденные вхождения обновлены до новых сигнатур

*VreaderTests.swift — обновление существующих тестов:*
- [ ] `testSaveAndLoadString`: `save/load` → `saveString/loadString`
- [ ] `testSaveAndLoadData`: `save/load` → `saveData/loadData`
- [ ] `testDeleteString`: `save/delete` → `saveString/deleteString`
- [ ] `testDeleteData`: исправлен баг (`saveData/deleteData`), `exists` заменён на `loadData` + проверку ошибки `.auth(.credentialsMissing)`
- [ ] `testLoadMissingKeyThrows`: `load` → `loadString`
- [ ] `testStringAndDataNoCollision`: `save/load` → `saveString/saveData/loadString/loadData`
- [ ] `testTypedOverloadDelegatesToRaw`: `save(key: KeychainKey)` → `saveString(key: KeychainKey)`, `load(key: String)` → `loadString(key: String)`
- [ ] `testOverwriteExistingKey`: `save/load` → `saveString/loadString`

*VreaderTests.swift — новые тесты:*
- [ ] `testIsSensitiveKeyReturnsTrueForAllCases`: проверяет все 9 случаев `KeychainKey` → `true`
- [ ] `testDeleteDataRemovesDataEntry`: `saveData` → `deleteData` → `loadData` бросает `.auth(.credentialsMissing)`
- [ ] `testDeleteStringDoesNotAffectData`: `saveString + saveData` → `deleteString` → `loadData` всё ещё возвращает данные
- [ ] `testSharedUsesAppGroupAccessGroup`: `KeychainManager.shared` не равен `KeychainManager()` по поведению (документальный тест через accessGroup)

*Финальная проверка:*
- [ ] Все тесты `KeychainManagerTests` проходят
- [ ] Все тесты `ThemeStoreTests` проходят (не должны быть сломаны)
- [ ] `python3 check_refs.py` завершается без ошибок
- [ ] Проект компилируется без предупреждений

**Risks:**
- `WebDAVProvider.swift` и потенциально другие файлы (`CloudProviderManager.swift`, `OnlineView.swift`) могут использовать старый API — перед кодогенерацией нужно проверить через `grep -rn "\.save(key:" App/Vreader/Vreader/`
- `DiagnosticsService` — `actor`, KeychainManager тоже `actor`; вызов `KeychainManager.isSensitiveKey` из DiagnosticsService должен быть `nonisolated` чтобы избежать `await` цепочки в логировании
- Тест `testSharedUsesAppGroupAccessGroup` на симуляторе может вести себя иначе, чем на устройстве с реальным App Group — ограничиться проверкой компиляции и инициализации без реальных Keychain-операций

---

## Verify

```yaml
- name: Поиск оставшихся вызовов старого API
  command: grep -rn "\.save(key:" App/Vreader/Vreader/ --include="*.swift" | grep -v KeychainManager.swift || echo "OK"

- name: Поиск вызовов .load( с возможной неоднозначностью
  command: grep -rn "km\.load\|shared\.load" App/Vreader/Vreader/ --include="*.swift" | grep -v KeychainManager.swift || echo "OK"

- name: check_refs.py валидация
  command: python3 check_refs.py 2>&1 | tail -30

- name: Сборка проекта (iOS Simulator)
  command: cd App/Vreader && xcodebuild -scheme Vreader -destination 'platform=iOS Simulator,OS=latest,name=iPhone 16' build -quiet 2>&1 | tail -10

- name: Юнит-тесты KeychainManagerTests
  command: cd App/Vreader && xcodebuild test -scheme Vreader -destination 'platform=iOS Simulator,OS=latest,name=iPhone 16' -only-testing:VreaderTests/KeychainManagerTests 2>&1 | grep -E "Test Suite|passed|failed|error:"

- name: Все юнит-тесты VreaderTests
  command: cd App/Vreader && xcodebuild test -scheme Vreader -destination 'platform=iOS Simulator,OS=latest,name=iPhone 16' -only-testing:VreaderTests 2>&1 | grep -E "Test Suite|passed|failed|error:"
```