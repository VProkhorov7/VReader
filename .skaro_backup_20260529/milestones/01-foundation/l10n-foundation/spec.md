# Specification: l10n-foundation (Обновленная версия)

## Context
Инвариант #4 запрещает хардкод строк в UI. Все пользовательские строки только через L10n.*. Существующие Localizable.strings для RU и EN нужно структурировать. L10n.swift обеспечивает типобезопасный доступ к строкам с поддержкой параметризации и плюрализации.

## User Scenarios
1. **Разработчик добавляет новую строку:** Добавляет ключ в L10n.swift (в соответствующий namespace) и соответствующие переводы в .strings файлы.
2. **Разработчик использует параметризованную строку:** Вызывает static func из namespace, например `L10n.Reader.pageOf(current: 5, total: 100)`.
3. **Разработчик работает с плюрализацией:** Вызывает функцию вроде `L10n.Common.books(count: 3)` для получения "3 книги".
4. **Миграция хардкод строк:** Находит существующие хардкод строки и отмечает их `// TODO: migrate to L10n.* in milestone 09` (если не критичные) или сразу мигрирует (если критичные).
5. **check_refs.py проверяет строки:** Валидирует, что все ключи в L10n.swift присутствуют в .strings файлах для RU и EN.

## Functional Requirements
- FR-01: Определить enum L10n с вложенными namespace: Library, Reader, Settings, Cloud, AI, Premium, Common, Errors, Onboarding
- FR-02: Каждый простой ключ — статическая вычисляемая переменная String, использующая NSLocalizedString с соответствующим ключом
- FR-03: Поддержка параметризованных строк через static func с использованием String(format:) или интерполяции (примеры: `L10n.Reader.pageOf(current: Int, total: Int)`, `L10n.Cloud.lastSyncTime(date: String)`)
- FR-04: Поддержка плюрализации для строк типа "1 книга / 2-4 книги / 5+ книг" через static func с логикой выбора формы по правилам RU (категории 1, 2-4, 5+) и EN (1 vs other)
- FR-05: Library namespace: title, searchPlaceholder, emptyState, addBook, sortBy, filterBy, collections, favorites, allBooks, recentlyRead, bookCount(Int)
- FR-06: Reader namespace: continueReading, chapter, page, of, translate, tts, notes, bookmarks, toc, settings, share, close, nextChapter, prevChapter, pageOf(current: Int, total: Int), chapterProgress(current: Int, total: Int)
- FR-07: Settings namespace: title, theme, font, fontSize, lineSpacing, language, cloud, premium, diagnostics, about, version, resetSettings
- FR-08: Cloud namespace: title, connect, disconnect, sync, lastSync, lastSyncTime(date: String), providers, icloud, webdav, yandex, nextcloud, mailru, google, dropbox, onedrive, smb, downloading, downloaded, cloudOnly, previewed, syncStatus(status: String)
- FR-09: AI namespace: translate, summary, xray, dictionary, tts, quota, quotaUsed, offline, premiumRequired, translating, generating, quotaRemaining(count: Int)
- FR-10: Premium namespace: title, subtitle, monthly, lifetime, restore, features, unlockThemes, unlockCloud, unlockAI, unlockTTS
- FR-11: Common namespace: ok, cancel, delete, edit, save, close, retry, loading, error, success, warning, unknown, done, back, books(count: Int) — для переиспользования в разных контекстах
- FR-12: Errors namespace: fileNotFound, networkOffline, cloudProviderError, aiServiceError, premiumRequired, syncFailed, parsingFailed
- FR-13: Вложенные enum'ы для группировки связанных ключей (примеры: L10n.Reader.ThemeNames (light, dark, sepia), L10n.Reader.Scroll (pageHorizontal, pageVertical, continuous))
- FR-14: Поддержка будущих локализаций (AR, ZH для milestone 09) — структура L10n.swift должна легко расширяться; комментарии о RTL-специфичных ключах где необходимо
- FR-15: Python скрипт (расширение check_refs.py) для валидации синхронизации между L10n.swift и .strings файлами: проверяет, что каждый ключ в L10n.swift присутствует в en.lproj/Localizable.strings и ru.lproj/Localizable.strings

## Non-Functional Requirements
- NFR-01: L10n.swift не должен содержать хардкод строк — только NSLocalizedString вызовы или логика плюрализации
- NFR-02: Все ключи в .strings файлах должны соответствовать ключам в L10n.swift (проверяется расширенным check_refs.py)
- NFR-03: Параметризованные функции должны использовать String(format:) с NSLocalizedString для поддержки локализованных форматов
- NFR-04: Плюрализация должна следовать правилам каждого языка: RU (1 книга / 2-4 книги / 5+ книг), EN (1 book / 2+ books)
- NFR-05: Существующие хардкод строки в UI файлах отмечаются TODO комментариями (некритичные) или сразу мигрируются (критичные для пользовательского опыта)

## Boundaries (что НЕ входит)
- Не добавлять AR и ZH локализации сейчас (milestone 09)
- Не реализовывать RTL layout (milestone 09) — только комментарии о RTL-специфичных ключах в коде
- Не переводить все строки профессионально — достаточно рабочих переводов на RU и EN
- Не менять существующие ключи в .strings файлах без согласования (backward compatibility)

## Acceptance Criteria
- [ ] L10n.swift определён со всеми namespace и вложенными enum'ами (Library, Reader, Settings, Cloud, AI, Premium, Common, Errors, Onboarding)
- [ ] Все простые ключи реализованы как статические вычисляемые переменные String
- [ ] Все параметризованные ключи реализованы как static func (примеры: pageOf, bookCount, lastSyncTime, quotaRemaining)
- [ ] Все плюрализированные ключи реализованы с корректной логикой для RU и EN (L10n.Common.books, L10n.Library.bookCount и т.д.)
- [ ] Вложенные enum'ы созданы для группировки связанных ключей (ThemeNames, Scroll и т.д.)
- [ ] ru.lproj/Localizable.strings содержит все ключи с русскими переводами
- [ ] en.lproj/Localizable.strings содержит все ключи с английскими переводами
- [ ] Существующие хардкод строки в LibraryView, SettingsView, ReaderView, CatalogsView либо помечены `// TODO: migrate to L10n.* in milestone 09`, либо мигрированы (критичные строки)
- [ ] Параметризованные функции работают корректно (String(format:) передаёт параметры в NSLocalizedString)
- [ ] Плюрализация работает для RU: 1 → форма 1, 2–4 → форма 2, 5+ → форма 3
- [ ] Плюрализация работает для EN: 1 → форма 1, other → форма 2
- [ ] Расширенный check_refs.py не находит неразрешённых L10n ключей и проверяет синхронизацию .strings файлов
- [ ] Код содержит комментарии о RTL и CJK специфичности ключей для milestone 09
- [ ] Общие ключи (done, cancel, back, ok) из L10n.Common переиспользуются везде вместо дублирования

## Implementation Notes

### Структура L10n.swift
```swift
// Примеры вложенных enum'ов:
enum L10n {
    enum Reader {
        enum ThemeNames {
            static var light: String { NSLocalizedString("reader.theme.light", defaultValue: "Light") }
            static var dark: String { NSLocalizedString("reader.theme.dark", defaultValue: "Dark") }
            static var sepia: String { NSLocalizedString("reader.theme.sepia", defaultValue: "Sepia") }
        }
        enum Scroll {
            // RTL-специфичные ключи для milestone 09
            static var pageHorizontal: String { NSLocalizedString("reader.scroll.pageHorizontal", defaultValue: "Page (Horizontal)") }
            static var pageVertical: String { NSLocalizedString("reader.scroll.pageVertical", defaultValue: "Page (Vertical)") }
        }
        static func pageOf(current: Int, total: Int) -> String {
            let format = NSLocalizedString("reader.pageOf", defaultValue: "Page %d of %d")
            return String(format: format, current, total)
        }
    }
    enum Common {
        static func books(count: Int) -> String {
            if Locale.current.languageCode == "ru" {
                let format: String
                let mod10 = count % 10
                let mod100 = count % 100
                if mod10 == 1 && mod100 != 11 {
                    format = NSLocalizedString("common.books.one", defaultValue: "%d книга")
                } else if (2...4).contains(mod10) && !(12...14).contains(mod100) {
                    format = NSLocalizedString("common.books.few", defaultValue: "%d книги")
                } else {
                    format = NSLocalizedString("common.books.many", defaultValue: "%d книг")
                }
                return String(format: format, count)
            } else {
                let format = count == 1 
                    ? NSLocalizedString("common.books.one", defaultValue: "%d book")
                    : NSLocalizedString("common.books.other", defaultValue: "%d books")
                return String(format: format, count)
            }
        }
    }
}
```

### Формат Localizable.strings
```
// ru.lproj/Localizable.strings
"reader.pageOf" = "Страница %d из %d";
"reader.theme.light" = "Светлая";
"reader.theme.dark" = "Тёмная";
"common.books.one" = "%d книга";
"common.books.few" = "%d книги";
"common.books.many" = "%d книг";
```

## Open Questions — RESOLVED
- ~~Использовать ли SwiftGen для автогенерации L10n или ручную реализацию?~~ **RESOLVED**: Ручная реализация с расширением check_refs.py для валидации синхронизации (FR-15)
- ~~Как обрабатывать pluralization?~~ **RESOLVED**: Static func с логикой RU/EN плюрализации (FR-04)