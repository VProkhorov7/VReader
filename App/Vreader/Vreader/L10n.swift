import Foundation
import SwiftUI

// MARK: - L10n namespace

enum L10n {

    // MARK: Tabs
    enum Tab {
        static let library  = String(localized: "tab.library",  defaultValue: "Библиотека")
        static let reading  = String(localized: "tab.reading",  defaultValue: "Читаю")
        static let catalogs = String(localized: "tab.catalogs", defaultValue: "Каталоги")
        static let settings = String(localized: "tab.settings", defaultValue: "Настройки")
        static let home     = String(localized: "tab.home",     defaultValue: "Дом")
    }

    // MARK: Library
    enum Library {
        static let title         = String(localized: "library.title",         defaultValue: "Библиотека")
        static let emptyTitle    = String(localized: "library.empty.title",   defaultValue: "Библиотека пуста")
        static let emptyMessage  = String(localized: "library.empty.message", defaultValue: "Добавьте книги с устройства\nили подключите облачное хранилище")
        static let addBook       = String(localized: "library.add_book",      defaultValue: "Добавить книгу")
        static let delete        = String(localized: "library.delete",        defaultValue: "Удалить")
        static let fromDevice    = String(localized: "library.from_device",   defaultValue: "С устройства / iCloud Drive")
        static let chooseSource  = String(localized: "library.choose_source", defaultValue: "Выберите источник")
    }

    // MARK: ReaderKeys
    enum ReaderKeys {
        static let contents        = String(localized: "reader.contents",          defaultValue: "Содержание")
        static let appearance      = String(localized: "reader.appearance",        defaultValue: "Оформление")
        static let theme           = String(localized: "reader.theme",             defaultValue: "Тема")
        static let fontSize        = String(localized: "reader.font_size",         defaultValue: "Размер текста")
        static let lineSpacing     = String(localized: "reader.line_spacing",      defaultValue: "Межстрочный интервал")
        static let scrollMode      = String(localized: "reader.scroll_mode",       defaultValue: "Режим листания")
        static let languageScript  = String(localized: "reader.language_script",   defaultValue: "Язык / направление")
        static let verticalText    = String(localized: "reader.vertical_text",     defaultValue: "Вертикальный текст")
        static let verticalTextHint = String(localized: "reader.vertical_text.hint", defaultValue: "Для китайского, японского")
        static let rtlHint           = String(localized: "reader.rtl_hint",            defaultValue: "Направление (RTL) для арабского определяется автоматически")
        static let unsupportedFormats = String(localized: "reader.unsupported_formats", defaultValue: "Поддерживаемые форматы: PDF, EPUB, FB2, TXT, RTF, CBZ, CBR, MP3, M4B")

        enum ThemeNames {
            static let light = String(localized: "reader.theme.light", defaultValue: "Светлая")
            static let sepia = String(localized: "reader.theme.sepia", defaultValue: "Сепия")
            static let dark  = String(localized: "reader.theme.dark",  defaultValue: "Тёмная")
        }

        enum Scroll {
            static let pageHorizontal   = String(localized: "reader.scroll.page_h",     defaultValue: "Страницами →")
            static let scrollVertical   = String(localized: "reader.scroll.vertical",   defaultValue: "Полотно ↕")
            static let scrollHorizontal = String(localized: "reader.scroll.horizontal", defaultValue: "Полотно →")
        }

        enum SpacingKeys {
            static let narrow  = String(localized: "reader.spacing.narrow",  defaultValue: "Узкий")
            static let medium  = String(localized: "reader.spacing.medium",  defaultValue: "Средний")
            static let wide    = String(localized: "reader.spacing.wide",    defaultValue: "Широкий")
        }

        static let read          = String(localized: "reader.read",          defaultValue: "Читать")
        static let continueRead  = String(localized: "reader.continue",      defaultValue: "Продолжить чтение")
        static let notDownloaded = String(localized: "reader.not_downloaded",defaultValue: "Книга не скачана")
        static let download      = String(localized: "reader.download",      defaultValue: "Скачать")
        static let finished      = String(localized: "reader.finished",      defaultValue: "Прочитано")
        static let beginning     = String(localized: "reader.beginning",     defaultValue: "Начало")
        static let end           = String(localized: "reader.end",           defaultValue: "Конец")
        static let chapters      = String(localized: "reader.chapters",      defaultValue: "Главы")
        static let chapter       = String(localized: "reader.chapter",       defaultValue: "Глава")
        static let inProgress    = String(localized: "reader.in_progress",   defaultValue: "В процессе")
    }

    // MARK: Settings
    enum Settings {
        static let title        = String(localized: "settings.title",         defaultValue: "Настройки")
        static let appearance   = String(localized: "settings.appearance",    defaultValue: "Оформление")
        static let font         = String(localized: "settings.font",          defaultValue: "Шрифт")
        static let fontPicker   = String(localized: "settings.font_picker",   defaultValue: "Выбор шрифта")
        static let fontSize     = String(localized: "settings.font_size",     defaultValue: "Размер шрифта")
        static let storage      = String(localized: "settings.storage",       defaultValue: "Хранилища")
        static let cloud        = String(localized: "settings.cloud",         defaultValue: "Добавить хранилище")
        static let sync         = String(localized: "settings.sync",          defaultValue: "Синхронизация")
        static let syncDetail   = String(localized: "settings.sync.detail",   defaultValue: "Прогресс и закладки синхронизируются через iCloud")
        static let ai           = String(localized: "settings.ai",            defaultValue: "Искусственный интеллект")
        static let aiSoon       = String(localized: "settings.ai.soon",       defaultValue: "ИИ-функции (скоро)")
        static let app          = String(localized: "settings.app",           defaultValue: "Приложение")
        static let version      = String(localized: "settings.version",       defaultValue: "Версия")
        static let feedback     = String(localized: "settings.feedback",      defaultValue: "Написать в поддержку")
        static let review       = String(localized: "settings.review",        defaultValue: "Оставить отзыв")
        static let dev          = String(localized: "settings.dev",           defaultValue: "Разработка")
    }

    // MARK: Comic
    enum Comic {
        static let opening      = String(localized: "comic.opening",        defaultValue: "Открываю...")
        static let noImages     = String(localized: "comic.no_images",      defaultValue: "Изображения не найдены")
        static let fileNotFound = String(localized: "comic.file_not_found", defaultValue: "Файл не найден")
        static let cbtPending   = String(localized: "comic.cbt_pending",    defaultValue: "Формат CBT (TAR) будет поддержан в следующем обновлении.")
        static let cbrNoLib     = String(localized: "comic.cbr_no_lib",     defaultValue: "требует библиотеку UnRAR. Пока поддерживается только CBZ. Конвертируйте архив с помощью Calibre.")
        static let archiveError = String(localized: "comic.archive_error",  defaultValue: "Не удалось открыть архив: ")
    }

    // MARK: Audio
    enum Audio {
        static let chapters = String(localized: "audio.chapters", defaultValue: "Главы")
        static let noFile   = String(localized: "audio.no_file",  defaultValue: "Файл не найден")
    }

    // MARK: CHM
    enum CHM {
        static let title         = String(localized: "chm.title",          defaultValue: "CHM — дань олдам")
        static let fileNotFound  = String(localized: "chm.not_found",      defaultValue: "Файл не найден")
        static let notDownloaded = String(localized: "chm.not_downloaded", defaultValue: "Файл не скачан")
    }

    // MARK: Catalogs
    enum Catalogs {
        static let title      = String(localized: "catalogs.title",       defaultValue: "Каталоги")
        static let storage    = String(localized: "catalogs.storage",     defaultValue: "Хранилища")
        static let free       = String(localized: "catalogs.free",        defaultValue: "Бесплатные")
        static let connected  = String(localized: "catalogs.connected",   defaultValue: "Подключённые")
        static let available  = String(localized: "catalogs.available",   defaultValue: "Доступные")
        static let disconnect = String(localized: "catalogs.disconnect",  defaultValue: "Отключить")
        static let connect    = String(localized: "catalogs.connect",     defaultValue: "Подключить")
        static let stores     = String(localized: "catalogs.stores",      defaultValue: "Магазины")
        static let comingSoon = String(localized: "catalogs.coming_soon", defaultValue: "Скоро")
        static let builtin    = String(localized: "catalogs.builtin",     defaultValue: "Встроено в систему")

        enum OPDS {
            static let addTitle        = String(localized: "opds.add_title",   defaultValue: "Добавить OPDS")
            static let catalog         = String(localized: "opds.catalog",     defaultValue: "Каталог")
            static let namePlaceholder = String(localized: "opds.name_ph",     defaultValue: "Название (например, Calibre Home)")
            static let urlPlaceholder  = String(localized: "opds.url_ph",      defaultValue: "Адрес OPDS")
            static let urlHint         = String(localized: "opds.url_hint",    defaultValue: "Адрес должен оканчиваться на /opds или /opds/v1.2")
            static let authSection     = String(localized: "opds.auth",        defaultValue: "Авторизация (если требуется)")
            static let serverOk        = String(localized: "opds.server_ok",   defaultValue: "OPDS-сервер отвечает")
            static let serverFail      = String(localized: "opds.server_fail", defaultValue: "Не удалось подключиться")
        }

        enum CloudForm {
            static let addTitle   = String(localized: "cloud_form.add_title",  defaultValue: "Добавить хранилище")
            static let service    = String(localized: "cloud_form.service",    defaultValue: "Сервис")
            static let type_      = String(localized: "cloud_form.type",       defaultValue: "Тип")
            static let connection = String(localized: "cloud_form.connection", defaultValue: "Подключение")
            static let serverAddr = String(localized: "cloud_form.server",     defaultValue: "Адрес сервера")
            static let login      = String(localized: "cloud_form.login",      defaultValue: "Логин")
            static let password   = String(localized: "cloud_form.password",   defaultValue: "Пароль")
            static let test       = String(localized: "cloud_form.test",       defaultValue: "Проверить соединение")
            static let testing    = String(localized: "cloud_form.testing",    defaultValue: "Проверяю...")
            static let testOk     = String(localized: "cloud_form.test_ok",    defaultValue: "Соединение успешно")
            static let testFail   = String(localized: "cloud_form.test_fail",  defaultValue: "Ошибка подключения")
        }
    }

    // MARK: Common
    enum Common {
        static let cancel  = String(localized: "common.cancel",  defaultValue: "Отмена")
        static let done    = String(localized: "common.done",     defaultValue: "Готово")
        static let back    = String(localized: "common.back",     defaultValue: "Назад")
        static let error   = String(localized: "common.error",    defaultValue: "Ошибка")
        static let reading = String(localized: "common.reading",  defaultValue: "Чтение")
        static let add     = String(localized: "common.add",      defaultValue: "Добавить")
        static let delete  = String(localized: "common.delete",   defaultValue: "Удалить")
    }

    // MARK: AppThemeNames
    enum AppThemeNames {
        static let premiumRequired = String(
            localized: "app_theme.premium_required",
            defaultValue: "Эта тема доступна только в Premium-версии"
        )
    }

    // MARK: - Errors

    enum Errors {
        enum FileSystem {
            static let fileNotFoundDescription = String(localized: "error.file_system.file_not_found.description", defaultValue: "Файл не найден в указанном пути")
            static let fileNotFoundRecovery = String(localized: "error.file_system.file_not_found.recovery", defaultValue: "Файл может быть перемещён или удалён. Попробуйте повторно импортировать книгу")

            static let permissionDeniedDescription = String(localized: "error.file_system.permission_denied.description", defaultValue: "Нет доступа к файлу")
            static let permissionDeniedRecovery = String(localized: "error.file_system.permission_denied.recovery", defaultValue: "Проверьте права доступа в параметрах приложения")

            static let bookmarkStaleDescription = String(localized: "error.file_system.bookmark_stale.description", defaultValue: "Закладка файла устарела")
            static let bookmarkStaleRecovery = String(localized: "error.file_system.bookmark_stale.recovery", defaultValue: "Повторно импортируйте книгу или добавьте её в доступное хранилище")

            static let diskFullDescription = String(localized: "error.file_system.disk_full.description", defaultValue: "На устройстве недостаточно свободного места")
            static let diskFullRecovery = String(localized: "error.file_system.disk_full.recovery", defaultValue: "Удалите ненужные файлы и повторите попытку")

            static let readFailedDescription = String(localized: "error.file_system.read_failed.description", defaultValue: "Ошибка чтения файла")
            static let readFailedRecovery = String(localized: "error.file_system.read_failed.recovery", defaultValue: "Попробуйте повторно открыть файл")

            static let writeFailedDescription = String(localized: "error.file_system.write_failed.description", defaultValue: "Ошибка записи файла")
            static let writeFailedRecovery = String(localized: "error.file_system.write_failed.recovery", defaultValue: "Проверьте доступное место и попробуйте снова")

            static let deleteFailedDescription = String(localized: "error.file_system.delete_failed.description", defaultValue: "Ошибка удаления файла")
            static let deleteFailedRecovery = String(localized: "error.file_system.delete_failed.recovery", defaultValue: "Проверьте права доступа и попробуйте снова")

            static let moveFailedDescription = String(localized: "error.file_system.move_failed.description", defaultValue: "Ошибка перемещения файла")
            static let moveFailedRecovery = String(localized: "error.file_system.move_failed.recovery", defaultValue: "Попробуйте перемещение в другое место")

            static let copyFailedDescription = String(localized: "error.file_system.copy_failed.description", defaultValue: "Ошибка копирования файла в библиотеку")
            static let copyFailedRecovery = String(localized: "error.file_system.copy_failed.recovery", defaultValue: "Проверьте доступное место и права доступа")

            static let createDirectoryFailedDescription = String(localized: "error.file_system.create_directory_failed.description", defaultValue: "Ошибка создания папки")
            static let createDirectoryFailedRecovery = String(localized: "error.file_system.create_directory_failed.recovery", defaultValue: "Проверьте права доступа и попробуйте снова")

            static let invalidPathDescription = String(localized: "error.file_system.invalid_path.description", defaultValue: "Неверный путь файла")
            static let invalidPathRecovery = String(localized: "error.file_system.invalid_path.recovery", defaultValue: "Проверьте путь и повторите попытку")

            static let fileAlreadyExistsDescription = String(localized: "error.file_system.file_already_exists.description", defaultValue: "Файл с таким именем уже существует")
            static let fileAlreadyExistsRecovery = String(localized: "error.file_system.file_already_exists.recovery", defaultValue: "Переименуйте файл или удалите существующий")

            static let fileAccessDeniedDescription = String(localized: "error.file_system.file_access_denied.description", defaultValue: "Доступ к файлу запрещён")
            static let fileAccessDeniedRecovery = String(localized: "error.file_system.file_access_denied.recovery", defaultValue: "Проверьте права доступа в параметрах приложения")
        }

        enum Network {
            static let unavailableDescription = String(localized: "error.network.unavailable.description", defaultValue: "Сетевое соединение недоступно")
            static let unavailableRecovery = String(localized: "error.network.unavailable.recovery", defaultValue: "Проверьте Wi-Fi или мобильное соединение и повторите попытку")

            static let offlineDescription = String(localized: "error.network.offline.description", defaultValue: "Вы находитесь в режиме офлайн")
            static let offlineRecovery = String(localized: "error.network.offline.recovery", defaultValue: "Подключитесь к сети для выполнения этого действия")

            static let timeoutDescription = String(localized: "error.network.timeout.description", defaultValue: "Время ожидания истекло")
            static let timeoutRecovery = String(localized: "error.network.timeout.recovery", defaultValue: "Попробуйте позже или используйте более быстрое соединение")

            static let cancelledDescription = String(localized: "error.network.cancelled.description", defaultValue: "Запрос был отменён")
            static let cancelledRecovery = String(localized: "error.network.cancelled.recovery", defaultValue: "Повторите попытку")

            static let invalidResponseDescription = String(localized: "error.network.invalid_response.description", defaultValue: "Сервер вернул неверный ответ")
            static let invalidResponseRecovery = String(localized: "error.network.invalid_response.recovery", defaultValue: "Попробуйте позже")

            static let invalidStatusCodeDescription = String(localized: "error.network.invalid_status_code.description", defaultValue: "Сервер вернул ошибку")
            static let invalidStatusCodeRecovery = String(localized: "error.network.invalid_status_code.recovery", defaultValue: "Проверьте адрес и повторите попытку")

            static let requestFailedDescription = String(localized: "error.network.request_failed.description", defaultValue: "Ошибка при отправке запроса")
            static let requestFailedRecovery = String(localized: "error.network.request_failed.recovery", defaultValue: "Проверьте подключение и повторите попытку")

            static let downloadFailedDescription = String(localized: "error.network.download_failed.description", defaultValue: "Ошибка при скачивании файла")
            static let downloadFailedRecovery = String(localized: "error.network.download_failed.recovery", defaultValue: "Проверьте соединение и повторите попытку")

            static let uploadFailedDescription = String(localized: "error.network.upload_failed.description", defaultValue: "Ошибка при загрузке файла")
            static let uploadFailedRecovery = String(localized: "error.network.upload_failed.recovery", defaultValue: "Проверьте соединение и попробуйте снова")

            static let decodingFailedDescription = String(localized: "error.network.decoding_failed.description", defaultValue: "Ошибка декодирования ответа")
            static let decodingFailedRecovery = String(localized: "error.network.decoding_failed.recovery", defaultValue: "Попробуйте позже")

            static let encodingFailedDescription = String(localized: "error.network.encoding_failed.description", defaultValue: "Ошибка кодирования запроса")
            static let encodingFailedRecovery = String(localized: "error.network.encoding_failed.recovery", defaultValue: "Повторите попытку")

            static let rateLimitedDescription = String(localized: "error.network.rate_limited.description", defaultValue: "Слишком много запросов. Попробуйте позже")
            static let rateLimitedRecovery = String(localized: "error.network.rate_limited.recovery", defaultValue: "Подождите несколько минут и повторите")

            static let serverErrorDescription = String(localized: "error.network.server_error.description", defaultValue: "Ошибка сервера")
            static let serverErrorRecovery = String(localized: "error.network.server_error.recovery", defaultValue: "Попробуйте позже")
        }

        enum CloudProvider {
            static let providerUnavailableDescription = String(localized: "error.cloud_provider.provider_unavailable.description", defaultValue: "Облачный сервис недоступен")
            static let providerUnavailableRecovery = String(localized: "error.cloud_provider.provider_unavailable.recovery", defaultValue: "Проверьте подключение к сервису и повторите попытку")

            static let credentialsMissingDescription = String(localized: "error.cloud_provider.credentials_missing.description", defaultValue: "Учётные данные отсутствуют")
            static let credentialsMissingRecovery = String(localized: "error.cloud_provider.credentials_missing.recovery", defaultValue: "Переподключите облачное хранилище в параметрах")

            static let authenticationFailedDescription = String(localized: "error.cloud_provider.authentication_failed.description", defaultValue: "Ошибка аутентификации")
            static let authenticationFailedRecovery = String(localized: "error.cloud_provider.authentication_failed.recovery", defaultValue: "Проверьте учётные данные и повторите попытку")

            static let authorizationFailedDescription = String(localized: "error.cloud_provider.authorization_failed.description", defaultValue: "Доступ запрещён")
            static let authorizationFailedRecovery = String(localized: "error.cloud_provider.authorization_failed.recovery", defaultValue: "Проверьте права доступа в параметрах сервиса")

            static let accountNotFoundDescription = String(localized: "error.cloud_provider.account_not_found.description", defaultValue: "Аккаунт не найден")
            static let accountNotFoundRecovery = String(localized: "error.cloud_provider.account_not_found.recovery", defaultValue: "Подключитесь заново")

            static let resourceNotFoundDescription = String(localized: "error.cloud_provider.resource_not_found.description", defaultValue: "Ресурс не найден на сервере")
            static let resourceNotFoundRecovery = String(localized: "error.cloud_provider.resource_not_found.recovery", defaultValue: "Проверьте путь на сервере и повторите попытку")

            static let quotaExceededDescription = String(localized: "error.cloud_provider.quota_exceeded.description", defaultValue: "Квота хранилища превышена")
            static let quotaExceededRecovery = String(localized: "error.cloud_provider.quota_exceeded.recovery", defaultValue: "Удалите ненужные файлы на сервере")

            static let conflictDescription = String(localized: "error.cloud_provider.conflict.description", defaultValue: "Конфликт версий файла")
            static let conflictRecovery = String(localized: "error.cloud_provider.conflict.recovery", defaultValue: "Обновите и повторите попытку")

            static let invalidResponseDescription = String(localized: "error.cloud_provider.invalid_response.description", defaultValue: "Неверный ответ сервера")
            static let invalidResponseRecovery = String(localized: "error.cloud_provider.invalid_response.recovery", defaultValue: "Попробуйте позже")

            static let unsupportedProviderDescription = String(localized: "error.cloud_provider.unsupported_provider.description", defaultValue: "Этот сервис не поддерживается")
            static let unsupportedProviderRecovery = String(localized: "error.cloud_provider.unsupported_provider.recovery", defaultValue: "Выберите другой сервис")

            static let syncFailedDescription = String(localized: "error.cloud_provider.sync_failed.description", defaultValue: "Ошибка синхронизации")
            static let syncFailedRecovery = String(localized: "error.cloud_provider.sync_failed.recovery", defaultValue: "Проверьте соединение и повторите попытку")

            static let downloadFailedDescription = String(localized: "error.cloud_provider.download_failed.description", defaultValue: "Ошибка при скачивании из облака")
            static let downloadFailedRecovery = String(localized: "error.cloud_provider.download_failed.recovery", defaultValue: "Проверьте соединение и повторите попытку")

            static let uploadFailedDescription = String(localized: "error.cloud_provider.upload_failed.description", defaultValue: "Ошибка при загрузке в облако")
            static let uploadFailedRecovery = String(localized: "error.cloud_provider.upload_failed.recovery", defaultValue: "Проверьте соединение и доступное место")
        }

        enum Auth {
            static let credentialsMissingDescription = String(localized: "error.auth.credentials_missing.description", defaultValue: "Учётные данные отсутствуют в Keychain")
            static let credentialsMissingRecovery = String(localized: "error.auth.credentials_missing.recovery", defaultValue: "Пожалуйста, введите учётные данные заново")

            static let invalidCredentialsDescription = String(localized: "error.auth.invalid_credentials.description", defaultValue: "Неверные учётные данные")
            static let invalidCredentialsRecovery = String(localized: "error.auth.invalid_credentials.recovery", defaultValue: "Проверьте логин и пароль")

            static let tokenExpiredDescription = String(localized: "error.auth.token_expired.description", defaultValue: "Токен доступа истёк")
            static let tokenExpiredRecovery = String(localized: "error.auth.token_expired.recovery", defaultValue: "Пожалуйста, переподключитесь")

            static let tokenMissingDescription = String(localized: "error.auth.token_missing.description", defaultValue: "Токен доступа отсутствует")
            static let tokenMissingRecovery = String(localized: "error.auth.token_missing.recovery", defaultValue: "Подключитесь заново")

            static let refreshFailedDescription = String(localized: "error.auth.refresh_failed.description", defaultValue: "Ошибка обновления токена")
            static let refreshFailedRecovery = String(localized: "error.auth.refresh_failed.recovery", defaultValue: "Переподключитесь")

            static let accessDeniedDescription = String(localized: "error.auth.access_denied.description", defaultValue: "Доступ запрещён")
            static let accessDeniedRecovery = String(localized: "error.auth.access_denied.recovery", defaultValue: "Проверьте права доступа")

            static let sessionExpiredDescription = String(localized: "error.auth.session_expired.description", defaultValue: "Сеанс истёк")
            static let sessionExpiredRecovery = String(localized: "error.auth.session_expired.recovery", defaultValue: "Пожалуйста, войдите заново")

            static let biometryUnavailableDescription = String(localized: "error.auth.biometry_unavailable.description", defaultValue: "Биометрия недоступна")
            static let biometryUnavailableRecovery = String(localized: "error.auth.biometry_unavailable.recovery", defaultValue: "Включите биометрию в параметрах устройства")

            static let biometryFailedDescription = String(localized: "error.auth.biometry_failed.description", defaultValue: "Ошибка биометрической аутентификации")
            static let biometryFailedRecovery = String(localized: "error.auth.biometry_failed.recovery", defaultValue: "Попробуйте снова")

            static let keychainFailedDescription = String(localized: "error.auth.keychain_failed.description", defaultValue: "Ошибка доступа к Keychain")
            static let keychainFailedRecovery = String(localized: "error.auth.keychain_failed.recovery", defaultValue: "Убедитесь, что приложение имеет доступ к Keychain, и повторите попытку")
        }

        enum Parsing {
            static let unsupportedFormatDescription = String(localized: "error.parsing.unsupported_format.description", defaultValue: "Формат файла не поддерживается")
            static let unsupportedFormatRecovery = String(localized: "error.parsing.unsupported_format.recovery", defaultValue: "Поддерживаемые форматы: EPUB, FB2, PDF, DjVu, CBZ, CBR, TXT, RTF, MP3, M4B")

            static let invalidFormatDescription = String(localized: "error.parsing.invalid_format.description", defaultValue: "Неверный формат файла")
            static let invalidFormatRecovery = String(localized: "error.parsing.invalid_format.recovery", defaultValue: "Файл может быть повреждён. Попробуйте переимпортировать")

            static let corruptedDataDescription = String(localized: "error.parsing.corrupted_data.description", defaultValue: "Данные файла повреждены")
            static let corruptedDataRecovery = String(localized: "error.parsing.corrupted_data.recovery", defaultValue: "Попробуйте переимпортировать файл или скачайте его заново")

            static let missingRequiredFieldDescription = String(localized: "error.parsing.missing_required_field.description", defaultValue: "В файле отсутствует обязательное поле")
            static let missingRequiredFieldRecovery = String(localized: "error.parsing.missing_required_field.recovery", defaultValue: "Файл может быть неполным или повреждён")

            static let decodingFailedDescription = String(localized: "error.parsing.decoding_failed.description", defaultValue: "Ошибка декодирования файла")
            static let decodingFailedRecovery = String(localized: "error.parsing.decoding_failed.recovery", defaultValue: "Попробуйте переимпортировать файл")

            static let encodingFailedDescription = String(localized: "error.parsing.encoding_failed.description", defaultValue: "Ошибка кодирования данных")
            static let encodingFailedRecovery = String(localized: "error.parsing.encoding_failed.recovery", defaultValue: "Повторите попытку")

            static let emptyContentDescription = String(localized: "error.parsing.empty_content.description", defaultValue: "Файл не содержит контента")
            static let emptyContentRecovery = String(localized: "error.parsing.empty_content.recovery", defaultValue: "Проверьте файл и повторите попытку")

            static let unsupportedEncodingDescription = String(localized: "error.parsing.unsupported_encoding.description", defaultValue: "Кодировка файла не поддерживается")
            static let unsupportedEncodingRecovery = String(localized: "error.parsing.unsupported_encoding.recovery", defaultValue: "Попробуйте конвертировать файл в UTF-8")

            static let metadataExtractionFailedDescription = String(localized: "error.parsing.metadata_extraction_failed.description", defaultValue: "Ошибка извлечения метаданных")
            static let metadataExtractionFailedRecovery = String(localized: "error.parsing.metadata_extraction_failed.recovery", defaultValue: "Вы можете вручную добавить информацию о книге")
        }

        enum StoreKit {
            static let productNotFoundDescription = String(localized: "error.storekit.product_not_found.description", defaultValue: "Товар не найден в App Store")
            static let productNotFoundRecovery = String(localized: "error.storekit.product_not_found.recovery", defaultValue: "Попробуйте позже")

            static let purchaseFailedDescription = String(localized: "error.storekit.purchase_failed.description", defaultValue: "Ошибка при покупке")
            static let purchaseFailedRecovery = String(localized: "error.storekit.purchase_failed.recovery", defaultValue: "Проверьте метод оплаты и повторите попытку")

            static let purchaseCancelledDescription = String(localized: "error.storekit.purchase_cancelled.description", defaultValue: "Покупка отменена")
            static let purchaseCancelledRecovery = String(localized: "error.storekit.purchase_cancelled.recovery", defaultValue: "Вы можете повторить попытку позже")

            static let verificationFailedDescription = String(localized: "error.storekit.verification_failed.description", defaultValue: "Ошибка проверки покупки")
            static let verificationFailedRecovery = String(localized: "error.storekit.verification_failed.recovery", defaultValue: "Попробуйте восстановить покупку")

            static let premiumRequiredDescription = String(localized: "error.storekit.premium_required.description", defaultValue: "Эта функция требует Premium-подписку")
            static let premiumRequiredRecovery = String(localized: "error.storekit.premium_required.recovery", defaultValue: "Обновитесь до Premium, чтобы разблокировать все функции")

            static let restoreFailedDescription = String(localized: "error.storekit.restore_failed.description", defaultValue: "Ошибка восстановления покупок")
            static let restoreFailedRecovery = String(localized: "error.storekit.restore_failed.recovery", defaultValue: "Попробуйте позже")

            static let receiptMissingDescription = String(localized: "error.storekit.receipt_missing.description", defaultValue: "Квитанция покупки отсутствует")
            static let receiptMissingRecovery = String(localized: "error.storekit.receipt_missing.recovery", defaultValue: "Попробуйте восстановить покупку")

            static let receiptInvalidDescription = String(localized: "error.storekit.receipt_invalid.description", defaultValue: "Квитанция покупки недействительна")
            static let receiptInvalidRecovery = String(localized: "error.storekit.receipt_invalid.recovery", defaultValue: "Попробуйте восстановить покупку")

            static let notEntitledDescription = String(localized: "error.storekit.not_entitled.description", defaultValue: "У вас нет прав на эту покупку")
            static let notEntitledRecovery = String(localized: "error.storekit.not_entitled.recovery", defaultValue: "Проверьте статус подписки")
        }

        enum Sync {
            static let conflictDetectedDescription = String(localized: "error.sync.conflict_detected.description", defaultValue: "Обнаружен конфликт синхронизации")
            static let conflictDetectedRecovery = String(localized: "error.sync.conflict_detected.recovery", defaultValue: "Выберите версию для сохранения")

            static let mergeFailedDescription = String(localized: "error.sync.merge_failed.description", defaultValue: "Ошибка объединения изменений")
            static let mergeFailedRecovery = String(localized: "error.sync.merge_failed.recovery", defaultValue: "Попробуйте синхронизировать позже")

            static let cloudUnavailableDescription = String(localized: "error.sync.cloud_unavailable.description", defaultValue: "Облако недоступно")
            static let cloudUnavailableRecovery = String(localized: "error.sync.cloud_unavailable.recovery", defaultValue: "Проверьте подключение к iCloud")

            static let pushFailedDescription = String(localized: "error.sync.push_failed.description", defaultValue: "Ошибка отправки изменений")
            static let pushFailedRecovery = String(localized: "error.sync.push_failed.recovery", defaultValue: "Проверьте соединение и повторите попытку")

            static let pullFailedDescription = String(localized: "error.sync.pull_failed.description", defaultValue: "Ошибка получения изменений")
            static let pullFailedRecovery = String(localized: "error.sync.pull_failed.recovery", defaultValue: "Проверьте соединение и повторите попытку")

            static let invalidStateDescription = String(localized: "error.sync.invalid_state.description", defaultValue: "Неверное состояние синхронизации")
            static let invalidStateRecovery = String(localized: "error.sync.invalid_state.recovery", defaultValue: "Перезагрузите приложение")

            static let versionMismatchDescription = String(localized: "error.sync.version_mismatch.description", defaultValue: "Несовместимые версии данных")
            static let versionMismatchRecovery = String(localized: "error.sync.version_mismatch.recovery", defaultValue: "Обновите приложение до последней версии")

            static let serializationFailedDescription = String(localized: "error.sync.serialization_failed.description", defaultValue: "Ошибка сериализации данных")
            static let serializationFailedRecovery = String(localized: "error.sync.serialization_failed.recovery", defaultValue: "Повторите попытку")

            static let deserializationFailedDescription = String(localized: "error.sync.deserialization_failed.description", defaultValue: "Ошибка десериализации данных")
            static let deserializationFailedRecovery = String(localized: "error.sync.deserialization_failed.recovery", defaultValue: "Попробуйте позже")
        }

        enum AI {
            static let apiKeyMissingDescription = String(localized: "error.ai.api_key_missing.description", defaultValue: "API-ключ Gemini отсутствует")
            static let apiKeyMissingRecovery = String(localized: "error.ai.api_key_missing.recovery", defaultValue: "Добавьте API-ключ в параметрах приложения")

            static let apiKeyInvalidDescription = String(localized: "error.ai.api_key_invalid.description", defaultValue: "API-ключ недействителен")
            static let apiKeyInvalidRecovery = String(localized: "error.ai.api_key_invalid.recovery", defaultValue: "Проверьте и обновите API-ключ в параметрах")

            static let requestFailedDescription = String(localized: "error.ai.request_failed.description", defaultValue: "Ошибка при отправке запроса к AI")
            static let requestFailedRecovery = String(localized: "error.ai.request_failed.recovery", defaultValue: "Проверьте соединение и повторите попытку")

            static let invalidResponseDescription = String(localized: "error.ai.invalid_response.description", defaultValue: "Неверный ответ от AI")
            static let invalidResponseRecovery = String(localized: "error.ai.invalid_response.recovery", defaultValue: "Попробуйте позже")

            static let rateLimitedDescription = String(localized: "error.ai.rate_limited.description", defaultValue: "Лимит запросов к AI превышен")
            static let rateLimitedRecovery = String(localized: "error.ai.rate_limited.recovery", defaultValue: "Подождите несколько минут и повторите")

            static let quotaExceededDescription = String(localized: "error.ai.quota_exceeded.description", defaultValue: "Квота AI исчерпана")
            static let quotaExceededRecovery = String(localized: "error.ai.quota_exceeded.recovery", defaultValue: "Ваш лимит на использование AI достигнут")

            static let modelUnavailableDescription = String(localized: "error.ai.model_unavailable.description", defaultValue: "Модель AI недоступна")
            static let modelUnavailableRecovery = String(localized: "error.ai.model_unavailable.recovery", defaultValue: "Попробуйте позже")

            static let contentBlockedDescription = String(localized: "error.ai.content_blocked.description", defaultValue: "Контент заблокирован политиками AI")
            static let contentBlockedRecovery = String(localized: "error.ai.content_blocked.recovery", defaultValue: "Попробуйте с другим текстом")

            static let unsupportedLanguageDescription = String(localized: "error.ai.unsupported_language.description", defaultValue: "Язык не поддерживается")
            static let unsupportedLanguageRecovery = String(localized: "error.ai.unsupported_language.recovery", defaultValue: "Выберите поддерживаемый язык")

            static let generationFailedDescription = String(localized: "error.ai.generation_failed.description", defaultValue: "Ошибка генерации AI")
            static let generationFailedRecovery = String(localized: "error.ai.generation_failed.recovery", defaultValue: "Попробуйте ещё раз")
        }
    }
}