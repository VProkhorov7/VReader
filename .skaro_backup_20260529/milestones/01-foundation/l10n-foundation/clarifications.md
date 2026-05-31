# Clarifications: 01-foundation::l10n-foundation

## Question 1
Как реализовать поддержку плюрализации для строк типа '1 книга / 2-4 книги / 5+ книг' в L10n.swift?

*Context:* Спецификация упоминает pluralization в Open Questions, но не определяет механизм. Это требуется для UI строк типа 'количество книг', 'количество страниц'.

**Options:**
- A) Реализовать методы типа L10n.Common.books(count: Int) -> String с логикой выбора формы по правилам RU/EN
- B) Использовать NSLocalizedString с .stringsdict файлами (Xcode native pluralization)
- C) Отложить до milestone 09, пока не будет полной локализации; пока использовать простые форматированные строки

**Answer:**
Реализовать методы типа L10n.Common.books(count: Int) -> String с логикой выбора формы по правилам RU/EN

## Question 2
Должны ли существующие хардкод строки в UI файлах (LibraryView, SettingsView, ReaderView) быть полностью мигрированы на L10n.* сейчас или отмечены TODO?

*Context:* В текущих файлах есть десятки хардкод строк типа 'Готово', 'Назад', 'Чтение'. Полная миграция требует больших изменений; TODO даст гибкость.

**Options:**
- A) Полностью мигрировать все хардкод строки на L10n.* в этой задаче (включить в scope)
- B) Отметить хардкод строки как // TODO: migrate to L10n.* in milestone 09, исправить только критичные
- C) Создать отдельный файл HardcodedStringsToMigrate.swift с TODO списком для check_refs.py

**Answer:**
Отметить хардкод строки как // TODO: migrate to L10n.* in milestone 09, исправить только критичные

## Question 3
Как обрабатывать динамические строки с параметрами (например, 'Страница %d из %d' или 'Из %@')?

*Context:* L10n.Library.from_account уже содержит %@ в .strings. Нужно определить паттерн для всех параметризованных строк.

**Options:**
- A) Использовать static func в каждом namespace: L10n.Reader.pageOf(current: Int, total: Int) -> String с String(format:) внутри
- B) Использовать String(localized:) с интерполяцией Swift 5.1+: L10n.Reader.pageOf = { current, total in String(localized: "Page \(current) of \(total)") }
- C) Оставить как NSLocalizedString с %d/%@, вызывающий код отвечает за форматирование

**Answer:**
Использовать static func в каждом namespace: L10n.Reader.pageOf(current: Int, total: Int) -> String с String(format:) внутри

## Question 4
Должна ли структура L10n.swift содержать вложенные enum'ы (как сейчас: Library, ReaderKeys, Settings) или плоскую структуру с namespace'ами?

*Context:* Текущий код использует вложенные enum'ы (ThemeNames, Scroll, SpacingKeys внутри ReaderKeys). Это влияет на читаемость и консистентность FR-03-FR-10.

**Options:**
- A) Сохранить вложенные enum'ы для группировки: L10n.Reader.ThemeNames.light, L10n.Reader.Scroll.pageHorizontal
- B) Использовать плоскую структуру с точками: L10n.reader.theme.light, L10n.reader.scroll.pageHorizontal
- C) Гибридный подход: основные категории (Library, Reader, Settings) как enum'ы, вложенные группы только где нужно

**Answer:**
Сохранить вложенные enum'ы для группировки: L10n.Reader.ThemeNames.light, L10n.Reader.Scroll.pageHorizontal

## Question 5
Кто отвечает за синхронизацию между L10n.swift и .strings файлами — разработчик вручную или автоматический инструмент (SwiftGen, скрипт)?

*Context:* check_refs.py не проверяет наличие ключей в .strings. Несинхронизированные ключи приведут к runtime ошибкам NSLocalizedString.

**Options:**
- A) Разработчик вручную добавляет в оба места (L10n.swift и .strings); добавить проверку в check_refs.py
- B) Использовать SwiftGen для автогенерации L10n.swift из .strings файлов
- C) Создать простой Python скрипт (extend check_refs.py), который валидирует, что все ключи в L10n.swift присутствуют в .strings

**Answer:**
Создать простой Python скрипт (extend check_refs.py), который валидирует, что все ключи в L10n.swift присутствуют в .strings

## Question 6
Должен ли L10n.swift содержать структуру, готовую к AR (RTL) и ZH (CJK) локализациям (milestone 09), или ориентироваться только на RU/EN?

*Context:* Спецификация запрещает добавлять AR/ZH сейчас, но архитектура должна их поддерживать. Это влияет на организацию ключей.

**Options:**
- A) Структурировать L10n.swift так, чтобы легко добавить новые языки (комментарии о RTL-специфичных ключах для milestone 09)
- B) Сосредоточиться только на RU/EN; AR/ZH структура добавится в milestone 09 отдельно
- C) Добавить placeholder ключи для RTL строк (например, L10n.RTL.arabicHints), но не реализовывать

**Answer:**
Структурировать L10n.swift так, чтобы легко добавить новые языки (комментарии о RTL-специфичных ключах для milestone 09)

## Question 7
Как обрабатывать строки, которые повторяются в разных контекстах (например, 'Готово' в ReaderView, SettingsView, CatalogsView)?

*Context:* Избежать дублирования ключей при разных контекстах; улучшить переиспользование.

**Options:**
- A) Использовать общие ключи в L10n.Common (done, cancel, back) и переиспользовать везде
- B) Каждый контекст имеет свой ключ (reader.done, settings.done) для гибкости локализации
- C) Комбинированный подход: частые строки в Common, специфичные для контекста — в своих namespace'ах

**Answer:**
Использовать общие ключи в L10n.Common (done, cancel, back) и переиспользовать везде

Use a pragmatic localization foundation. Keep nested namespaces in L10n.swift for readability. Use static functions for dynamic strings and pluralization for RU/EN at this stage. Do not migrate all hardcoded UI strings in this task; mark non-critical ones as TODO for milestone 09 and fix only critical strings now. Add validation to check_refs.py or a small Python script to ensure L10n.swift keys exist in .strings. Prepare the structure for future AR/ZH/RTL support, but do not implement these languages yet. Use Common for truly shared strings and context-specific namespaces where translation meaning may differ.
