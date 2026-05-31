# Clarifications: 01-foundation::l10n-foundation

## Question 1
В коде используется enum ReaderKeys, но в спецификации везде enum Reader. При реализации L10n.swift следует переименовать ReaderKeys на Reader для соответствия спецификации или оставить текущее имя?

*Context:* Несоответствие имён может привести к ошибкам при импорте L10n в View файлы и противоречит спецификации FR-06.

**Options:**
- A) Переименовать ReaderKeys на Reader в L10n.swift при реализации (следовать спецификации)
- B) Оставить ReaderKeys как есть в коде (обновить спецификацию вместо кода)
- C) Создать оба: enum Reader как основной и typealias ReaderKeys = Reader для backward compatibility

**Answer:**
Создать оба: enum Reader как основной и typealias ReaderKeys = Reader для backward compatibility

## Question 2
В проекте уже существуют ru.lproj/Localizable.strings и en.lproj/Localizable.strings с ключами и переводами. При создании L10n.swift следует переиспользовать существующие ключи из .strings файлов или создавать новые ключи как определено в спецификации?

*Context:* Несинхронизированные ключи приведут к дублированию или потере существующих переводов, что влияет на масштаб работы по обновлению .strings файлов.

**Options:**
- A) Аудировать все существующие ключи в .strings и переиспользовать их в L10n.swift (минимальные изменения .strings)
- B) Создавать новые ключи в L10n.swift как в спецификации и обновлять .strings файлы соответственно (полная переструктуризация)
- C) Гибридный подход: переиспользовать существующие ключи где они подходят, создавать новые для FR-05 до FR-12

**Answer:**
Создавать новые ключи в L10n.swift как в спецификации и обновлять .strings файлы соответственно (полная переструктуризация)

## Question 3
В AppError.swift factory methods используют локализованные описания из L10n.Errors (например, L10n.Errors.FileSystem.fileNotFoundDescription). Как синхронизировать enum'ы ErrorCode с L10n.Errors ключами — нужна ли обязательная 1-1 correspondence между каждым ErrorCode.case и L10n.Errors ключом, или они могут быть независимы?

*Context:* Без явной связи между ErrorCode и L10n ключами может быть сложно поддерживать соответствие и валидировать полноту локализации ошибок.

**Options:**
- A) Обязательная 1-1 correspondence: каждый ErrorCode.case должен иметь соответствующий L10n.Errors ключ (add validation в check_refs.py)
- B) ErrorCode и L10n.Errors независимы: factory methods вручную выбирают L10n ключ по контексту (гибче, сложнее поддерживать)
- C) Создать отдельный enum ErrorLocalizer, который маппит ErrorCode → L10n.Errors ключи

**Answer:**
ErrorCode и L10n.Errors независимы: factory methods вручную выбирают L10n ключ по контексту (гибче, сложнее поддерживать)

## Question 4
При расширении check_refs.py для валидации L10n.swift ↔ .strings файлов — какие проверки добавить: только наличие ключей в .strings, или также проверку корректности параметров (count %d, %@), наличия ключей во всех языках (RU и EN), и отсутствие неиспользуемых ключей в .strings?

*Context:* Полнота проверок влияет на надёжность инструмента и раннее обнаружение ошибок локализации, но может усложнить валидацию.

**Options:**
- A) Базовая проверка: наличие каждого L10n.swift ключа в ru.lproj и en.lproj Localizable.strings
- B) Расширенная проверка: + валидация параметров (%d, %@) + проверка String(format:) синтаксиса
- C) Максимальная проверка: + отсутствие неиспользуемых ключей в .strings + warning на неполные переводы

**Answer:**
Максимальная проверка: + отсутствие неиспользуемых ключей в .strings + warning на неполные переводы

## Question 5
Спецификация показывает плюрализацию только для RU (1 книга / 2-4 книги / 5+ книг) и EN (1 book / other books). Нужна ли общая абстракция для pluralization rules в L10n.swift, готовая для расширения на AR/ZH/другие языки в milestone 09, или это будет добавлено позже как отдельный рефакторинг?

*Context:* Ранняя абстракция предотвратит рефакторинг всех plural функций в milestone 09, но может усложнить текущую реализацию.

**Options:**
- A) Реализовать pluralization как простые static func с RU/EN логикой (no abstraction, refactor in milestone 09)
- B) Создать protocol PluralRules с language-specific реализациями (готово к расширению, но overcomplicated сейчас)
- C) Использовать Locale.current.languageCode для выбора pluralization rules из dictionary (средний уровень абстракции)

**Answer:**
Создать protocol PluralRules с language-specific реализациями (готово к расширению, но overcomplicated сейчас)

## Question 6
Acceptance Criteria требует 'отметить хардкод строки TODO или мигрировать (критичные)'. Какие критерии определяют 'критичную' строку: только UI, видимую пользователю (например, ReaderTopBar labels), или также system messages (например, 'Ошибка') и toast notifications?

*Context:* Определение scope миграции влияет на объём работы и может потребовать пересмотра критериев для каждого View файла.

**Options:**
- A) Критичные = только main UI labels и buttons в Reader, Library, Settings (минимальный scope)
- B) Критичные = all user-facing strings (labels, buttons, messages, notifications) кроме debug и temporary (средний scope)
- C) Критичные = все строки в исходных файлах (максимальный scope, полная миграция сейчас)

**Answer:**
Критичные = all user-facing strings (labels, buttons, messages, notifications) кроме debug и temporary (средний scope)
