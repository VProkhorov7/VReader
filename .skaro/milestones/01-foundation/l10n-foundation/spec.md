# Specification: l10n-foundation (Обновленная версия v2)

## Context
Инвариант #4 запрещает хардкод строк в UI. Все пользовательские строки только через L10n.*. Существующие Localizable.strings для RU и EN нужно структурировать. L10n.swift обеспечивает типобезопасный доступ к строкам с поддержкой параметризации и плюрализации. Полная переструктуризация .strings файлов в соответствии со спецификацией.

## User Scenarios
1. **Разработчик добавляет новую строку:** Добавляет ключ в L10n.swift (в соответствующий namespace) и соответствующие переводы в .strings файлы.
2. **Разработчик использует параметризованную строку:** Вызывает static func из namespace, например `L10n.Reader.pageOf(current: 5, total: 100)`.
3. **Разработчик работает с плюрализацией:** Вызывает функцию вроде `L10n.Common.books(count: 3)` для получения "3 книги".
4. **Миграция хардкод строк:** Находит существующие хардкод строки и отмечает их `// TODO: migrate to L10n.* in milestone 09` (если не критичные) или сразу мигрирует (если критичные — все пользовательские строки в UI, кнопках, сообщениях, уведомлениях).
5. **check_refs.py проверяет строки:** Валидирует наличие ключей в .strings, отсутствие неиспользуемых ключей, полноту переводов для RU и EN.
6. **Разработчик работает с legacy ReaderKeys:** Использует `typealias ReaderKeys = Reader` для backward compatibility.
7. **Разработчик подготавливает код к AR/ZH:** Использует `protocol PluralRules` для language-specific плюрализации, готовый к расширению в milestone 09.

## Functional Requirements
- FR-01: Определить enum L10n с вложенными namespace: Library, Reader, Settings, Cloud, AI, Premium, Common, Errors, Onboarding
- FR-02: Каждый простой ключ — статическая вычисляемая переменная String, использующая NSLocalizedString с соответствующим ключом
- FR-03: Поддержка параметризованных строк через static func с использованием String(format:) или интерполяции (примеры: `L10n.Reader.pageOf(current: Int, total: Int)`, `L10n.Cloud.lastSyncTime(date: String)`)
- FR-04: Поддержка плюрализации для строк типа "1 книга / 2-4 книги / 5+ книг" через static func с логикой выбора формы по правилам RU (категории 1, 2-4, 5+) и EN (1 vs other); логика должна использовать `protocol PluralRules` с language-specific реализациями для подготовки к AR/ZH в milestone 09
- FR-05: Library namespace: title, searchPlaceholder, emptyState, addBook, sortBy, filterBy, collections, favorites, allBooks, recentlyRead, bookCount(Int)
- FR-06: Reader namespace: continueReading, chapter, page, of, translate, tts, notes, bookmarks, toc, settings, share, close, nextChapter, prevChapter, pageOf(current: Int, total: Int), chapterProgress(current: Int, total: Int)
- FR-07: Settings namespace: title, theme, font, fontSize, lineSpacing, language, cloud, premium, diagnostics, about, version, resetSettings
- FR-08: Cloud namespace: title, connect, disconnect, sync, lastSync, lastSyncTime(date: String), providers, icloud, webdav, yandex, nextcloud, mailru, google, dropbox, onedrive, smb, downloading, downloaded, cloudOnly, previewed, syncStatus(status: String)
- FR-09: AI namespace: translate, summary, xray, dictionary, tts, quota, quotaUsed, offline, premiumRequired, translating, generating, quotaRemaining(count: Int)
- FR-10: Premium namespace: title, subtitle, monthly, lifetime, restore, features, unlockThemes, unlockCloud, unlockAI, unlockTTS
- FR-11: Common namespace: ok, cancel, delete, edit, save, close, retry, loading, error, success, warning, unknown, done, back, books(count: Int) — для переиспользования в разных контекстах
- FR-12: Errors namespace: fileNotFound, networkOffline, cloudProviderError, aiServiceError, premiumRequired, syncFailed, parsingFailed (независимы от ErrorCode в AppError.swift; factory methods вручную выбирают L10n ключ по контексту)
- FR-13: Вложенные enum'ы для группировки связанных ключей (примеры: L10n.Reader.ThemeNames (light, dark, sepia), L10n.Reader.Scroll (pageHorizontal, pageVertical, continuous))
- FR-14: Поддержка будущих локализаций (AR, ZH для milestone 09) — структура L10n.swift должна легко расширяться через protocol PluralRules; комментарии о RTL-специфичных ключах где необходимо
- FR-15: Python скрипт (расширение check_refs.py) для валидации синхронизации между L10n.swift и .strings файлами: проверяет наличие каждого ключа в L10n.swift в en.lproj/Localizable.strings и ru.lproj/Localizable.strings, отсутствие неиспользуемых ключей в .strings файлах, warning на неполные переводы
- FR-16: Создать enum Reader как основной и `typealias ReaderKeys = Reader` для backward compatibility со старым кодом

## Non-Functional Requirements
- NFR-01: L10n.swift не должен содержать хардкод строк — только NSLocalizedString вызовы или логика плюрализации
- NFR-02: Все ключи в .strings файлах должны соответствовать ключам в L10n.swift (проверяется расширенным check_refs.py)
- NFR-03: Параметризованные функции должны использовать String(format:) с NSLocalizedString для поддержки локализованных форматов
- NFR-04: Плюрализация должна следовать правилам каждого языка через protocol PluralRules: RU (1 книга / 2-4 книги / 5+ книг), EN (1 book / 2+ books)
- NFR-05: Все пользовательские строки в UI (labels, buttons, messages, notifications) должны быть мигрированы в L10n.* или помечены TODO; debug и temporary строки исключены из обязательной миграции
- NFR-06: ErrorCode в AppError.swift и L10n.Errors независимы; factory methods вручную выбирают L10n ключ по контексту для гибкости
- NFR-07: Полная переструктуризация .strings файлов в соответствии со спецификацией; существующие ключи обновляются в новый формат

## Boundaries (что НЕ входит)
- Не добавлять AR и ZH локализации сейчас (milestone 09), но protocol PluralRules подготавливает архитектуру
- Не реализовывать RTL layout (milestone 09) — только комментарии о RTL-специфичных ключах в коде
- Не переводить все строки профессионально — достаточно рабочих переводов на RU и EN
- Не создавать новые языки в .lproj директориях кроме ru.lproj и en.lproj
- Не менять существующие ErrorCode.case в AppError.swift — только добавлять L10n соответствия

## Acceptance Criteria
- [ ] L10n.swift определён со всеми namespace и вложенными enum'ами (Library, Reader, Settings, Cloud, AI, Premium, Common, Errors, Onboarding)
- [ ] enum Reader создан как основной, создан `typealias ReaderKeys = Reader` для backward compatibility
- [ ] Все простые ключи реализованы как статические вычисляемые переменные String
- [ ] Все параметризованные ключи реализованы как static func (примеры: pageOf, bookCount, lastSyncTime, quotaRemaining)
- [ ] Все плюрализированные ключи реализованы с использованием protocol PluralRules с language-specific логикой для RU и EN
- [ ] protocol PluralRules определён с методами для RU (1, 2-4, 5+ категории) и EN (1 vs other) плюрализации, готовый к расширению на AR/ZH
- [ ] Вложенные enum'ы созданы для группировки связанных ключей (ThemeNames, Scroll и т.д.)
- [ ] ru.lproj/Localizable.strings полностью переструктурирован в соответствии со спецификацией и содержит все ключи с русскими переводами
- [ ] en.lproj/Localizable.strings полностью переструктурирован в соответствии со спецификацией и содержит все ключи с английскими переводами
- [ ] Все пользовательские строки в UI (labels, buttons, messages, notifications) в LibraryView, SettingsView, ReaderView, CatalogsView мигрированы на L10n.* (без исключений)
- [ ] Параметризованные функции работают корректно (String(format:) передаёт параметры в NSLocalizedString)
- [ ] Плюрализация работает для RU: 1 → форма 1, 2–4 → форма 2, 5+ → форма 3
- [ ] Плюрализация работает для EN: 1 → форма 1, other → форма 2
- [ ] ErrorCode и L10n.Errors независимы; factory methods в AppError.swift вручную выбирают L10n ключ по контексту
- [ ] Расширенный check_refs.py валидирует: (1) наличие каждого L10n ключа в .strings файлах, (2) отсутствие неиспользуемых ключей в .strings, (3) warning на неполные переводы, (4) корректность параметров (%d, %@)
- [ ] check_refs.py проверяет наличие ключей во всех языках (RU и EN)
- [ ] Код содержит комментарии о RTL и CJK специфичности ключей для milestone 09
- [ ] Общие ключи (done, cancel, back, ok) из L10n.Common переиспользуются везде вместо дублирования

## Implementation Notes

### Структура L10n.swift с protocol PluralRules

```swift
/// Протокол для language-specific правил плюрализации (готов к AR/ZH в milestone 09)
protocol PluralRules {
    /// Возвращает индекс формы (0, 1, 2) для количества в текущем языке
    static func formIndex(for count: Int) -> Int
}

/// Русские правила плюрализации: 1 книга / 2-4 книги / 5+ книг
struct RussianPluralRules: PluralRules {
    static func formIndex(for count: Int) -> Int {
        let mod10 = count % 10
        let mod100 = count % 100
        if mod10 == 1 && mod100 != 11 {
            return 0 // одна книга
        } else if (2...4).contains(mod10) && !(12...14).contains(mod100) {
            return 1 // две-четыре книги
        } else {
            return 2 // пять и более книг
        }
    }
}

/// Английские правила плюрализации: 1 book / 2+ books
struct EnglishPluralRules: PluralRules {
    static func formIndex(for count: Int) -> Int {
        return count == 1 ? 0 : 1
    }
}

enum L10n {
    enum Reader {
        enum ThemeNames {
            // RTL-специфичные ключи для milestone 09
            static var light: String { NSLocalizedString("reader.theme.light", defaultValue: "Light") }
            static var dark: String { NSLocalizedString("reader.theme.dark", defaultValue: "Dark") }
            static var sepia: String { NSLocalizedString("reader.theme.sepia", defaultValue: "Sepia") }
        }
        enum Scroll {
            // RTL-специфичные ключи для milestone 09
            static var pageHorizontal: String { NSLocalizedString("reader.scroll.pageHorizontal", defaultValue: "Page (Horizontal)") }
            static var pageVertical: String { NSLocalizedString("reader.scroll.pageVertical", defaultValue: "Page (Vertical)") }
            static var continuous: String { NSLocalizedString("reader.scroll.continuous", defaultValue: "Continuous") }
        }
        static func pageOf(current: Int, total: Int) -> String {
            let format = NSLocalizedString("reader.pageOf", defaultValue: "Page %d of %d")
            return String(format: format, current, total)
        }
        static func chapterProgress(current: Int, total: Int) -> String {
            let format = NSLocalizedString("reader.chapterProgress", defaultValue: "Chapter %d of %d")
            return String(format: format, current, total)
        }
    }
    
    // typealias для backward compatibility
    typealias ReaderKeys = Reader
    
    enum Common {
        static func books(count: Int) -> String {
            let languageCode = Locale.current.languageCode ?? "en"
            let rules: PluralRules.Type = languageCode == "ru" ? RussianPluralRules.self : EnglishPluralRules.self
            let formIndex = rules.formIndex(for: count)
            
            if languageCode == "ru" {
                let keys = [
                    NSLocalizedString("common.books.one", defaultValue: "%d книга"),
                    NSLocalizedString("common.books.few", defaultValue: "%d книги"),
                    NSLocalizedString("common.books.many", defaultValue: "%d книг")
                ]
                let format = keys[formIndex]
                return String(format: format, count)
            } else {
                let keys = [
                    NSLocalizedString("common.books.one", defaultValue: "%d book"),
                    NSLocalizedString("common.books.other", defaultValue: "%d books")
                ]
                let format = keys[formIndex]
                return String(format: format, count)
            }
        }
    }
}
```

### Формат переструктурированного Localizable.strings

```
// ru.lproj/Localizable.strings (полная переструктуризация)

// MARK: - Reader
"reader.pageOf" = "Страница %d из %d";
"reader.chapterProgress" = "Глава %d из %d";
"reader.theme.light" = "Светлая";
"reader.theme.dark" = "Тёмная";
"reader.theme.sepia" = "Сепия";
"reader.scroll.pageHorizontal" = "Страница (горизонтально)";
"reader.scroll.pageVertical" = "Страница (вертикально)";
"reader.scroll.continuous" = "Непрерывный скролл";

// MARK: - Common
"common.books.one" = "%d книга";
"common.books.few" = "%d книги";
"common.books.many" = "%d книг";
"common.ok" = "ОК";
"common.cancel" = "Отмена";
"common.done" = "Готово";
"common.back" = "Назад";
```

```
// en.lproj/Localizable.strings (полная переструктуризация)

// MARK: - Reader
"reader.pageOf" = "Page %d of %d";
"reader.chapterProgress" = "Chapter %d of %d";
"reader.theme.light" = "Light";
"reader.theme.dark" = "Dark";
"reader.theme.sepia" = "Sepia";
"reader.scroll.pageHorizontal" = "Page (Horizontal)";
"reader.scroll.pageVertical" = "Page (Vertical)";
"reader.scroll.continuous" = "Continuous";

// MARK: - Common
"common.books.one" = "%d book";
"common.books.other" = "%d books";
"common.ok" = "OK";
"common.cancel" = "Cancel";
"common.done" = "Done";
"common.back" = "Back";
```

### Обновлённые требования к check_refs.py

Расширенный скрипт должен проверять:

1. **Наличие ключей:** Каждый static var и static func в L10n.swift имеет соответствующие ключи в ru.lproj/Localizable.strings и en.lproj/Localizable.strings
2. **Отсутствие неиспользуемых ключей:** Каждый ключ в .strings файлах используется в L10n.swift (warning, не error)
3. **Полнота переводов:** Ключи присутствуют в обоих файлах (RU и EN); отсутствующие переводы — warning
4. **Корректность параметров:** Количество и тип параметров (%d, %@) в format строках соответствует параметрам static func
5. **Независимость ErrorCode и L10n.Errors:** Проверяет отсутствие обязательного 1-1 соответствия; warning если ключ в L10n.Errors не используется в AppError.swift
6. **Backward compatibility:** Проверяет наличие `typealias ReaderKeys = Reader` в L10n.swift

### Критерии критичной строки для миграции

Критичные = все пользовательские строки в UI:
- Labels и titles в View (ReaderTopBar, LibraryView, SettingsView)
- Buttons (кнопки действия, навигации)
- Messages (сообщения об ошибках, информационные сообщения)
- Notifications (toast, alerts, system notifications)

Исключены:
- Debug strings (внутренние логи)
- Temporary strings (временные заглушки)

## Open Questions — RESOLVED
- ~~Использовать ли SwiftGen для автогенерации L10n или ручную реализацию?~~ **RESOLVED**: Ручная реализация с расширением check_refs.py для валидации синхронизации (FR-15)
- ~~Как обрабатывать pluralization?~~ **RESOLVED**: protocol PluralRules с language-specific реализациями для RU и EN (FR-04, NFR-04)
- ~~ReaderKeys vs Reader?~~ **RESOLVED**: enum Reader основной, `typealias ReaderKeys = Reader` для backward compatibility (FR-16)
- ~~Переиспользовать существующие ключи или переструктурировать?~~ **RESOLVED**: Полная переструктуризация .strings файлов в соответствии со спецификацией (A2, NFR-07)
- ~~Синхронизация ErrorCode с L10n.Errors?~~ **RESOLVED**: Независимы; factory methods вручную выбирают L10n ключ по контексту (A3, FR-12, NFR-06)
- ~~Какие проверки в check_refs.py?~~ **RESOLVED**: Максимальная проверка — наличие ключей, отсутствие неиспользуемых, warning на неполные переводы, корректность параметров (A4, FR-15)
- ~~Абстракция для pluralization rules?~~ **RESOLVED**: protocol PluralRules с language-specific реализациями для подготовки к AR/ZH (A5, FR-04, FR-14)
- ~~Какие строки критичные?~~ **RESOLVED**: All user-facing strings в UI (labels, buttons, messages, notifications) кроме debug и temporary (A6, NFR-05)

## Deliverables
1. **L10n.swift** с enum Reader (основной) + typealias ReaderKeys, всеми namespace'ами и protocol PluralRules
2. **protocol PluralRules** с RussianPluralRules и EnglishPluralRules реализациями
3. **ru.lproj/Localizable.strings** (переструктурирован)
4. **en.lproj/Localizable.strings** (переструктурирован)
5. **check_refs.py** (расширен для максимальной валидации)
6. **Миграция всех критичных строк** в UI компонентах на L10n.*

---

**Version:** 2.0  
**Last Updated:** Post Q&A Resolution  
**Status:** Ready for Implementation