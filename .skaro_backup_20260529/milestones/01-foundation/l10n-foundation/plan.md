## plan.md

## Stage 1: L10n Core — L10n.swift и Localizable.strings (RU/EN)

**Цель:** Реализовать полную типобезопасную систему локализации: расширить `L10n.swift` всеми namespace, параметризованными функциями и плюрализацией; добавить все новые ключи в оба `.strings` файла. Все три файла публикуются единым пакетом — они неразрывно связаны (ключ в `.swift` → запись в `.strings`).

**Зависит от:** нет

**Входы:**
- Спецификация FR-01 — FR-14, кларификации #1, #3, #4, #6, #7
- Существующий `App/Vreader/Vreader/L10n.swift` (сохранить backward compatibility)
- Существующие `ru.lproj/Localizable.strings`, `en.lproj/Localizable.strings` (расширить)

**Выходы:**
- `App/Vreader/Vreader/L10n.swift`
- `App/Vreader/Vreader/ru.lproj/Localizable.strings`
- `App/Vreader/Vreader/en.lproj/Localizable.strings`

**DoD:**
- [ ] `L10n.ReaderKeys` переименован в `L10n.Reader`; добавлен `typealias ReaderKeys = Reader` для обратной совместимости с существующим кодом
- [ ] Все namespace реализованы как вложенные `enum`: `Library`, `Reader`, `Settings`, `Cloud`, `AI`, `Premium`, `Common`, `Errors`, `Onboarding`
- [ ] Вложенные enum'ы сохранены и расширены: `L10n.Reader.ThemeNames`, `L10n.Reader.Scroll`, `L10n.Reader.Spacing`, `L10n.Catalogs.OPDS`, `L10n.Catalogs.CloudForm`
- [ ] Параметризованные `static func` реализованы: `L10n.Reader.pageOf(current:total:)`, `L10n.Reader.chapterProgress(current:total:)`, `L10n.Library.bookCount(_:)`, `L10n.Cloud.lastSyncTime(date:)`, `L10n.Cloud.syncStatus(status:)`, `L10n.AI.quotaRemaining(count:)`
- [ ] Плюрализация реализована в `L10n.Common.books(count:)` и `L10n.Library.bookCount(_:)`: RU — формы 1 / 2-4 / 5+ (по mod10/mod100), EN — 1 / other
- [ ] RTL-комментарии (`// RTL: milestone 09`) добавлены к ключам `L10n.Reader.Scroll.*` и другим направленно-зависимым ключам
- [ ] NFR-01 выполнен: `L10n.swift` не содержит ни одной хардкод строки — только `NSLocalizedString(...)` вызовы и логика плюрализации
- [ ] Каждый `NSLocalizedString`-ключ из `L10n.swift` присутствует в `ru.lproj/Localizable.strings`
- [ ] Каждый `NSLocalizedString`-ключ из `L10n.swift` присутствует в `en.lproj/Localizable.strings`
- [ ] Все существующие ключи сохранены (ни один ранее рабочий ключ не удалён)
- [ ] Ключи плюрализации в `.strings`: `common.books.one`, `common.books.few` (RU only), `common.books.many` / `common.books.other` (EN)

**Риски:**
- При мёрже с существующими `.strings` возможно дублирование ключей — нужно аккуратно проверить уникальность
- Переименование `ReaderKeys` → `Reader`: если в файлах за пределами предоставленных исходников есть прямые обращения к `L10n.ReaderKeys.*`, `typealias` их сохранит, но нужно убедиться, что `typealias` не создаёт конфликт типов

---

## Stage 2: Расширение check_refs.py + TODO-аннотации в UI файлах

**Цель:** Добавить в `check_refs.py` секцию валидации синхронизации L10n.swift ↔ .strings; мигрировать критичные хардкод строки в `ContentView`, `SettingsView`, `BookDetailView`; проставить `TODO` к некритичным строкам в `LibraryView`.

**Зависит от:** Stage 1 (нужны финальные ключи L10n.swift и .strings для корректной работы валидатора)

**Входы:**
- `App/Vreader/Vreader/L10n.swift` (Stage 1)
- `App/Vreader/Vreader/ru.lproj/Localizable.strings` (Stage 1)
- `App/Vreader/Vreader/en.lproj/Localizable.strings` (Stage 1)
- `Description/check_refs.py` (существующий — расширить)
- `App/Vreader/Vreader/ContentView.swift`, `SettingsView.swift`, `BookDetailView.swift`, `LibraryView.swift` (существующие)
- Кларификации #2, #5

**Выходы:**
- `Description/check_refs.py`
- `App/Vreader/Vreader/ContentView.swift`
- `App/Vreader/Vreader/SettingsView.swift`
- `App/Vreader/Vreader/BookDetailView.swift`
- `App/Vreader/Vreader/LibraryView.swift`

**DoD:**
- [ ] `check_refs.py` содержит новую секцию `# --- 7. L10n ключи ---`: парсит все `NSLocalizedString("...",` вызовы из `L10n.swift` регулярным выражением, сверяет с ключами в обоих `.strings` файлах
- [ ] Валидатор выводит `✅ Все L10n ключи синхронизированы` при успехе или `❌ НЕСИНХРОНИЗИРОВАННЫЕ L10n КЛЮЧИ:` с перечнем отсутствующих ключей
- [ ] `python3 check_refs.py` завершается с кодом `0` на текущем состоянии проекта после Stage 1
- [ ] Валидатор корректно обходит параметризованные функции (не ломается на `String(format:)` конструкциях)
- [ ] `ContentView.swift`: все 4 таб-строки (`"Библиотека"`, `"Читаю"`, `"Каталоги"`, `"Настройки"`) заменены на `L10n.Tab.*`; хардкод `#if DEBUG` строка `"Debug"` помечена `// TODO: migrate to L10n.* in milestone 09`
- [ ] `SettingsView.swift`: `.navigationTitle("Настройки")` → `L10n.Settings.title`; кнопка `"Готово"` → `L10n.Common.done`; все остальные хардкод строки (секции, слайдеры, версия, кнопки поддержки) помечены `// TODO: migrate to L10n.* in milestone 09`
- [ ] `BookDetailView.swift`: `"Читать"` → `L10n.ReaderKeys.read`; `"Скачать"` → `L10n.ReaderKeys.download`; `"Назад"` → `L10n.Common.back`; `"Отмена"` → `L10n.Common.cancel`; все остальные строки помечены TODO
- [ ] `LibraryView.swift`: оставшиеся хардкод строки (`"OK"`) помечены TODO; уже мигрированные строки не тронуты
- [ ] Ни один существующий тест (`VreaderTests`, `VreaderUITests`) не сломан
- [ ] `python3 check_refs.py` завершается с кодом `0` после всех изменений Stage 2

**Риски:**
- Парсер `check_refs.py` для `NSLocalizedString` ключей может дать ложные срабатывания на многострочные строки или escaping — нужна осторожная регулярка
- Миграция строк в `BookDetailView.swift` затрагивает условный код (`if book.isDownloaded`); нужно не нарушить логику ветвлений

---

## Verify

```yaml
- name: Основная валидация проекта (обёртка)
  command: python3 check_refs.py

- name: Прямой запуск канонического валидатора
  command: python3 Description/check_refs.py

- name: Проверка синтаксиса Python-валидатора
  command: python3 -m py_compile Description/check_refs.py

- name: Проверка отсутствия хардкод строк в L10n.swift (не должно быть defaultValue вне NSLocalizedString)
  command: python3 -c "import re, sys; content = open('App/Vreader/Vreader/L10n.swift').read(); bad = re.findall(r'(?<!NSLocalizedString\()\"[^\"]{3,}\"(?!\s*,\s*comment)', content); sys.exit(1) if bad else print('OK')"

- name: Проверка синхронизации ключей RU .strings с L10n.swift
  command: python3 -c "
import re
l10n = open('App/Vreader/Vreader/L10n.swift').read()
ru   = open('App/Vreader/Vreader/ru.lproj/Localizable.strings').read()
keys = re.findall(r'NSLocalizedString\(\"([^\"]+)\"', l10n)
missing = [k for k in keys if f'\"{k}\"' not in ru]
print('Missing RU keys:', missing) if missing else print('RU OK')
import sys; sys.exit(1 if missing else 0)
"

- name: Проверка синхронизации ключей EN .strings с L10n.swift
  command: python3 -c "
import re
l10n = open('App/Vreader/Vreader/L10n.swift').read()
en   = open('App/Vreader/Vreader/en.lproj/Localizable.strings').read()
keys = re.findall(r'NSLocalizedString\(\"([^\"]+)\"', l10n)
missing = [k for k in keys if f'\"{k}\"' not in en]
print('Missing EN keys:', missing) if missing else print('EN OK')
import sys; sys.exit(1 if missing else 0)
"

- name: Проверка отсутствия незамигрированных критичных строк в ContentView
  command: python3 -c "
content = open('App/Vreader/Vreader/ContentView.swift').read()
bad = ['\"Библиотека\"', '\"Читаю\"', '\"Каталоги\"', '\"Настройки\"']
found = [b for b in bad if b in content]
print('Не мигрированы:', found) if found else print('ContentView OK')
import sys; sys.exit(1 if found else 0)
"
```