# AI_NOTES — Stage 1: Рефакторинг KeychainManager — новый публичный API

## Что сделано
- Полностью переписан публичный API `KeychainManager.swift`
- `KeychainManager.shared` теперь инициализируется с `accessGroup: "com.vreader.shared"` (FR-01, NFR-03)
- Переименованы методы для строк: `save/load/delete` → `saveString/loadString/deleteString` (FR-02, FR-03, FR-04)
- Переименованы методы для данных: `save/load` → `saveData/loadData` (FR-05, FR-06)
- Добавлен новый метод `deleteData(key: String)` и `deleteData(key: KeychainKey)` (FR-07) — ранее отсутствовал
- Все шесть публичных методов продублированы с перегрузкой `key: KeychainKey` (FR-08)
- Добавлен `nonisolated func isSensitiveKey(_ key: KeychainKey) -> Bool` — всегда возвращает `true` (FR-12)
- Сохранены без изменений: `KeychainKey.isSynchronizable`, `KeychainKey.accessibility`, все приватные методы `performSave/performLoad/performDelete/performExists`
- Ни один метод не логирует `kSecValueData` — только `account` и `OSStatus` (NFR-04)

## Почему такой подход
- **Явные имена методов** (`saveString`/`saveData`) вместо перегрузки по типу результата устраняют неоднозначность Swift type inference и повышают читаемость (Clarification Q5, ответ B)
- **`nonisolated` для `isSensitiveKey`** — метод не обращается к изолированному состоянию actor, поэтому `DiagnosticsService` (тоже actor) может вызывать его без `await`, что критично для синхронного пути логирования (Clarification Q6, ответ B)
- **Префиксы `"str:"` и `"dat:"`** сохранены — обеспечивают раздельное хранение String и Data по одному логическому ключу без коллизий (Clarification Q2, ответ C)
- **`isSynchronizable = true`** только для OAuth-токенов (googleDrive*, dropbox*, oneDrive*) — строго по конституции; Gemini API, WebDAV, SMB — `false`, `ThisDeviceOnly` (конституция раздел Keychain)
- **`accessGroup: "com.vreader.shared"`** в `shared` — единая точка доступа для основного приложения и Widget extension без второго singleton (Clarification Q3, ответ B)

## Файлы созданы / изменены
| Файл | Действие | Описание |
|---|---|---|
| `App/Vreader/Vreader/KeychainManager.swift` | изменён | Полная перезапись публичного API: новые имена методов, `isSensitiveKey`, `deleteData`, `shared` с App Group |

## Риски и ограничения
- **Сломаны вызыватели** — `iCloudSettingsStore.swift` использует старые `save(key:value:)`, `load(key:)`, `delete(key:)`. Это ожидаемо по плану и исправляется в Stage 2
- **Тесты не скомпилируются** — `VreaderTests.swift` ссылается на старые сигнатуры. Исправляется в Stage 2
- **`deleteData` — новый метод** — существующий тест `testDeleteData` вызывал `delete(key:)` с `"str:"` префиксом (скрытый баг). Stage 2 исправляет тест и добавляет `testDeleteDataRemovesDataEntry`
- **`exists(key: KeychainKey)`** проверяет только `"str:"` префикс — соответствует существующему поведению; `existsData` не требуется по спецификации FR-11

## Соответствие инвариантам
- [x] `coverData: Data` в SwiftData запрещён — не затрагивается
- [x] Credentials только в Keychain — все операции идут через `KeychainManager`
- [x] OAuth только через `ASWebAuthenticationSession` — не затрагивается
- [x] Gemini API key только в Keychain — обеспечивается `KeychainKey.geminiAPIKey`
- [x] Нет PII в логах — `performSave/performLoad/performDelete` логируют только `account` (без значений) и `OSStatus`
- [x] `isPremium` sync через CloudKit запрещён — не затрагивается
- [x] `isSynchronizable` OAuth = true, локальные = false — сохранён без изменений
- [x] `kSecAttrAccessibleAfterFirstUnlock` для синхронизируемых, `ThisDeviceOnly` для локальных — NFR-02 выполнен

## Как проверить
1. Проверить типизацию файла изолированно:
   ```
   swiftc -typecheck App/Vreader/Vreader/KeychainManager.swift
   ```
2. Убедиться, что `shared` использует App Group:
   ```
   grep "com.vreader.shared" App/Vreader/Vreader/KeychainManager.swift
   ```
3. Убедиться, что старые методы `save(/load(/delete(` отсутствуют в публичном API (допустимы только в приватных `performSave` и т.д.):
   ```
   grep -n "func save\|func load\|func delete" App/Vreader/Vreader/KeychainManager.swift
   ```
4. Убедиться в наличии всех 12 публичных методов (6 строковых + 6 для String/KeychainKey):
   ```
   grep -c "func saveString\|func loadString\|func deleteString\|func saveData\|func loadData\|func deleteData" App/Vreader/Vreader/KeychainManager.swift
   ```