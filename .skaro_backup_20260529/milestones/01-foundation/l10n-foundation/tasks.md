# Tasks: l10n-foundation

## Stage 1: L10n Core — L10n.swift и Localizable.strings (RU/EN)

- [ ] Переименовать `L10n.ReaderKeys` → `L10n.Reader`; добавить `typealias ReaderKeys = Reader` внутри `L10n` для обратной совместимости → `App/Vreader/Vreader/L10n.swift`
- [ ] Расширить `L10n.Library`: добавить `searchPlaceholder`, `sortBy`, `filterBy`, `collections`, `favorites`, `allBooks`, `recentlyRead`; реализовать `static func bookCount(_ count: Int) -> String` с RU/EN плюрализацией → `App/Vreader/Vreader/L10n.swift`
- [ ] Расширить `L10n.Reader`: добавить `translate`, `tts`, `notes`, `bookmarks`, `toc`, `share`, `close`, `nextChapter`, `prevChapter`; реализовать `static func pageOf(current: Int, total: Int) -> String` и `static func chapterProgress(current: Int, total: Int) -> String` → `App/Vreader/Vreader/L10n.swift`
- [ ] Расширить вложенные enum'ы `L10n.Reader.ThemeNames`, `L10n.Reader.Scroll` (с RTL-комментариями `// RTL: milestone 09`), `L10n.Reader.Spacing` — сохранить существующие ключи → `App/Vreader/Vreader/L10n.swift`
- [ ] Расширить `L10n.Settings`: добавить `language`, `cloud`, `premium`, `diagnostics`, `about`, `resetSettings` → `App/Vreader/Vreader/L10n.swift`
- [ ] Реализовать `L10n.Cloud` с ключами: `title`, `connect`, `disconnect`, `sync`, `lastSync`, `providers`, `icloud`, `webdav`, `yandex`, `nextcloud`, `mailru`, `google`, `dropbox`, `onedrive`, `smb`, `downloading`, `downloaded`, `cloudOnly`, `previewed`; функции `lastSyncTime(date: String)`, `syncStatus(status: String)` → `App/Vreader/Vreader/L10n.swift`
- [ ] Реализовать `L10n.AI` с ключами: `translate`, `summary`, `xray`, `dictionary`, `tts`, `quota`, `quotaUsed`, `offline`, `premiumRequired`, `translating`, `generating`; функция `quotaRemaining(count: Int)` с RU/EN плюрализацией → `App/Vreader/Vreader/L10n.swift`
- [ ] Реализовать `L10n.Premium` с ключами: `title`, `subtitle`, `monthly`, `lifetime`, `restore`, `features`, `unlockThemes`, `unlockCloud`, `unlockAI`, `unlockTTS` → `App/Vreader/Vreader/L10n.swift`
- [ ] Расширить `L10n.Common`: добавить `ok`, `retry`, `loading`, `success`, `warning`, `unknown`, `add`; реализовать `static func books(count: Int) -> String` с RU-плюрализацией (mod10/mod100) и EN-плюрализацией (1 / other) → `App/Vreader/Vreader/L10n.swift`
- [ ] Реализовать `L10n.Onboarding` с базовыми ключами: `title`, `subtitle`, `getStarted`, `skip` → `App/Vreader/Vreader/L10n.swift`
- [ ] Добавить все новые ключи Stage 1 в `ru.lproj/Localizable.strings` (ключи плюрализации: `common.books.one`, `common.books.few`, `common.books.many`; все параметризованные форматы с `%d`/`%@`) → `App/Vreader/Vreader/ru.lproj/Localizable.strings`
- [ ] Добавить все новые ключи Stage 1 в `en.lproj/Localizable.strings` (ключи плюрализации: `common.books.one`, `common.books.other`; все параметризованные форматы) → `App/Vreader/Vreader/en.lproj/Localizable.strings`

## Stage 2: Расширение check_refs.py + TODO-аннотации в UI файлах

- [ ] Добавить секцию `# --- 7. L10n ключи ---` в `check_refs.py`: регулярным выражением извлечь все `NSLocalizedString("KEY"` из `L10n.swift`, проверить наличие каждого ключа в `ru.lproj` и `en.lproj`; вывести результат и установить `ok = False` при несоответствии → `Description/check_refs.py`
- [ ] Мигрировать Tab-строки `ContentView.swift` на `L10n.Tab.library`, `L10n.Tab.reading`, `L10n.Tab.catalogs`, `L10n.Tab.settings`; пометить `"Debug"` TODO → `App/Vreader/Vreader/ContentView.swift`
- [ ] Мигрировать `.navigationTitle("Настройки")` → `L10n.Settings.title` и кнопку `"Готово"` → `L10n.Common.done` в `SettingsView.swift`; все остальные хардкод строки пометить `// TODO: migrate to L10n.* in milestone 09` → `App/Vreader/Vreader/SettingsView.swift`
- [ ] Мигрировать критичные строки `BookDetailView.swift`: `"Читать"` → `L10n.ReaderKeys.read`, `"Скачать"` → `L10n.ReaderKeys.download`, `"Назад"` → `L10n.Common.back`, `"Отмена"` → `L10n.Common.cancel`; остальные пометить TODO → `App/Vreader/Vreader/BookDetailView.swift`
- [ ] Проставить `// TODO: migrate to L10n.* in milestone 09` к оставшимся хардкод строкам `LibraryView.swift` (строка `"OK"` в alert и прочие) → `App/Vreader/Vreader/LibraryView.swift`