import Foundation
import OSLog
import Security

// MARK: - KeychainKey

enum KeychainKey {
    case geminiAPIKey
    case googleDriveAccessToken
    case googleDriveRefreshToken
    case dropboxAccessToken
    case dropboxRefreshToken
    case oneDriveAccessToken
    case oneDriveRefreshToken
    case webDAVPassword(host: String)
    case smbPassword(host: String)

    /// Строковый идентификатор ключа для использования в Keychain account.
    var rawValue: String {
        switch self {
        case .geminiAPIKey:
            return "geminiAPIKey"
        case .googleDriveAccessToken:
            return "googleDriveAccessToken"
        case .googleDriveRefreshToken:
            return "googleDriveRefreshToken"
        case .dropboxAccessToken:
            return "dropboxAccessToken"
        case .dropboxRefreshToken:
            return "dropboxRefreshToken"
        case .oneDriveAccessToken:
            return "oneDriveAccessToken"
        case .oneDriveRefreshToken:
            return "oneDriveRefreshToken"
        case .webDAVPassword(let host):
            return "webDAVPassword.\(host)"
        case .smbPassword(let host):
            return "smbPassword.\(host)"
        }
    }

    /// OAuth-токены синхронизируются через iCloud Keychain.
    /// Локальные ключи (Gemini API, WebDAV, SMB) хранятся только на устройстве.
    var isSynchronizable: Bool {
        switch self {
        case .googleDriveAccessToken,
             .googleDriveRefreshToken,
             .dropboxAccessToken,
             .dropboxRefreshToken,
             .oneDriveAccessToken,
             .oneDriveRefreshToken:
            return true
        case .geminiAPIKey,
             .webDAVPassword,
             .smbPassword:
            return false
        }
    }

    /// Синхронизируемые ключи доступны после первой разблокировки устройства;
    /// локальные — только на данном устройстве после первой разблокировки.
    var accessibility: CFString {
        isSynchronizable
            ? kSecAttrAccessibleAfterFirstUnlock
            : kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
    }
}

// MARK: - KeychainManager

actor KeychainManager {

    // MARK: - Singleton

    /// Общий экземпляр с App Group accessGroup для доступа из основного приложения и Widget extension.
    static let shared = KeychainManager(accessGroup: "com.vreader.shared")

    // MARK: - Свойства

    private let service: String
    private let accessGroup: String?
    private let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier ?? "com.vreader.app",
        category: "KeychainManager"
    )

    // MARK: - Инициализация

    init(accessGroup: String? = nil) {
        self.service = Bundle.main.bundleIdentifier ?? "com.vreader.app"
        self.accessGroup = accessGroup
    }

    // MARK: - Публичный API: String + произвольный ключ

    /// Сохраняет строковое значение в Keychain по произвольному строковому ключу.
    func saveString(key: String, value: String) throws {
        guard let data = value.data(using: .utf8) else {
            throw AppError(
                code: .auth(.keychainFailed),
                description: L10n.Errors.Auth.keychainFailedDescription,
                recoveryHint: L10n.Errors.Auth.keychainFailedRecovery,
                underlyingDescription: "Ошибка кодирования значения в UTF-8"
            )
        }
        let account = accountString(prefix: "str", rawKey: key)
        try performSave(
            account: account,
            data: data,
            synchronizable: false,
            accessibility: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
        )
    }

    /// Загружает строковое значение из Keychain по произвольному строковому ключу.
    func loadString(key: String) throws -> String {
        let account = accountString(prefix: "str", rawKey: key)
        let data = try performLoad(account: account)
        guard let string = String(data: data, encoding: .utf8) else {
            logger.error("KeychainManager: декодирование UTF-8 не удалось для account=\(account, privacy: .public)")
            throw AppError(
                code: .auth(.keychainFailed),
                description: L10n.Errors.Auth.keychainFailedDescription,
                recoveryHint: L10n.Errors.Auth.keychainFailedRecovery,
                underlyingDescription: "Ошибка декодирования строки из Keychain"
            )
        }
        return string
    }

    /// Удаляет строковое значение из Keychain по произвольному строковому ключу.
    func deleteString(key: String) throws {
        let account = accountString(prefix: "str", rawKey: key)
        try performDelete(account: account)
    }

    // MARK: - Публичный API: Data + произвольный ключ

    /// Сохраняет бинарные данные в Keychain по произвольному строковому ключу.
    func saveData(key: String, data: Data) throws {
        let account = accountString(prefix: "dat", rawKey: key)
        try performSave(
            account: account,
            data: data,
            synchronizable: false,
            accessibility: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
        )
    }

    /// Загружает бинарные данные из Keychain по произвольному строковому ключу.
    func loadData(key: String) throws -> Data {
        let account = accountString(prefix: "dat", rawKey: key)
        return try performLoad(account: account)
    }

    /// Удаляет бинарные данные из Keychain по произвольному строковому ключу.
    func deleteData(key: String) throws {
        let account = accountString(prefix: "dat", rawKey: key)
        try performDelete(account: account)
    }

    // MARK: - Публичный API: exists + isSensitiveKey (произвольный ключ)

    /// Проверяет наличие строкового значения в Keychain без загрузки данных.
    func exists(key: String) -> Bool {
        let account = accountString(prefix: "str", rawKey: key)
        return performExists(account: account)
    }

    /// Все ключи KeychainKey являются credentials — метод всегда возвращает true.
    /// Используется DiagnosticsService для фильтрации чувствительных данных из логов.
    nonisolated func isSensitiveKey(_ key: KeychainKey) -> Bool {
        return true
    }

    // MARK: - Публичный API: String + KeychainKey

    /// Сохраняет строковое значение в Keychain по типизированному ключу
    /// с учётом isSynchronizable и accessibility ключа.
    func saveString(key: KeychainKey, value: String) throws {
        guard let data = value.data(using: .utf8) else {
            throw AppError(
                code: .auth(.keychainFailed),
                description: L10n.Errors.Auth.keychainFailedDescription,
                recoveryHint: L10n.Errors.Auth.keychainFailedRecovery,
                underlyingDescription: "Ошибка кодирования значения в UTF-8"
            )
        }
        let account = accountString(prefix: "str", rawKey: key.rawValue)
        try performSave(
            account: account,
            data: data,
            synchronizable: key.isSynchronizable,
            accessibility: key.accessibility
        )
    }

    /// Загружает строковое значение из Keychain по типизированному ключу.
    func loadString(key: KeychainKey) throws -> String {
        let account = accountString(prefix: "str", rawKey: key.rawValue)
        let data = try performLoad(account: account)
        guard let string = String(data: data, encoding: .utf8) else {
            logger.error("KeychainManager: декодирование UTF-8 не удалось для account=\(account, privacy: .public)")
            throw AppError(
                code: .auth(.keychainFailed),
                description: L10n.Errors.Auth.keychainFailedDescription,
                recoveryHint: L10n.Errors.Auth.keychainFailedRecovery,
                underlyingDescription: "Ошибка декодирования строки из Keychain"
            )
        }
        return string
    }

    /// Удаляет строковое значение из Keychain по типизированному ключу.
    func deleteString(key: KeychainKey) throws {
        let account = accountString(prefix: "str", rawKey: key.rawValue)
        try performDelete(account: account)
    }

    // MARK: - Публичный API: Data + KeychainKey

    /// Сохраняет бинарные данные в Keychain по типизированному ключу
    /// с учётом isSynchronizable и accessibility ключа.
    func saveData(key: KeychainKey, data: Data) throws {
        let account = accountString(prefix: "dat", rawKey: key.rawValue)
        try performSave(
            account: account,
            data: data,
            synchronizable: key.isSynchronizable,
            accessibility: key.accessibility
        )
    }

    /// Загружает бинарные данные из Keychain по типизированному ключу.
    func loadData(key: KeychainKey) throws -> Data {
        let account = accountString(prefix: "dat", rawKey: key.rawValue)
        return try performLoad(account: account)
    }

    /// Удаляет бинарные данные из Keychain по типизированному ключу.
    func deleteData(key: KeychainKey) throws {
        let account = accountString(prefix: "dat", rawKey: key.rawValue)
        try performDelete(account: account)
    }

    // MARK: - Публичный API: exists (KeychainKey)

    /// Проверяет наличие строкового значения в Keychain без загрузки данных
    /// (типизированный ключ).
    func exists(key: KeychainKey) -> Bool {
        let account = accountString(prefix: "str", rawKey: key.rawValue)
        return performExists(account: account)
    }

    // MARK: - Приватные вспомогательные методы

    private func accountString(prefix: String, rawKey: String) -> String {
        "\(prefix):\(rawKey)"
    }

    private func buildBaseQuery(
        account: String,
        synchronizable: Bool,
        accessibility: CFString
    ) -> [String: Any] {
        var query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecAttrAccessible as String: accessibility,
            kSecAttrSynchronizable as String: synchronizable ? kCFBooleanTrue! : kCFBooleanFalse!
        ]
        if let group = accessGroup {
            query[kSecAttrAccessGroup as String] = group
        }
        return query
    }

    private func buildLookupQuery(account: String) -> [String: Any] {
        var query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecAttrSynchronizable as String: kSecAttrSynchronizableAny,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        if let group = accessGroup {
            query[kSecAttrAccessGroup as String] = group
        }
        return query
    }

    private func buildDeleteQuery(account: String) -> [String: Any] {
        var query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecAttrSynchronizable as String: kSecAttrSynchronizableAny
        ]
        if let group = accessGroup {
            query[kSecAttrAccessGroup as String] = group
        }
        return query
    }

    private func buildExistsQuery(account: String) -> [String: Any] {
        var query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecAttrSynchronizable as String: kSecAttrSynchronizableAny,
            kSecReturnData as String: false,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        if let group = accessGroup {
            query[kSecAttrAccessGroup as String] = group
        }
        return query
    }

    // MARK: - Приватные операции Keychain

    private func performSave(
        account: String,
        data: Data,
        synchronizable: Bool,
        accessibility: CFString
    ) throws {
        // Удаляем существующую запись перед добавлением новой (upsert-паттерн)
        let deleteQuery = buildDeleteQuery(account: account)
        let deleteStatus = SecItemDelete(deleteQuery as CFDictionary)
        if deleteStatus != errSecSuccess && deleteStatus != errSecItemNotFound {
            logger.warning("KeychainManager: предварительное удаление не удалось для account=\(account, privacy: .public) status=\(deleteStatus)")
        }

        var addQuery = buildBaseQuery(
            account: account,
            synchronizable: synchronizable,
            accessibility: accessibility
        )
        addQuery[kSecValueData as String] = data

        let status = SecItemAdd(addQuery as CFDictionary, nil)
        guard status == errSecSuccess else {
            logger.error("KeychainManager: сохранение не удалось для account=\(account, privacy: .public) status=\(status)")
            throw AppError(
                code: .auth(.keychainFailed),
                description: L10n.Errors.Auth.keychainFailedDescription,
                recoveryHint: L10n.Errors.Auth.keychainFailedRecovery,
                underlyingDescription: "OSStatus: \(status)"
            )
        }
    }

    private func performLoad(account: String) throws -> Data {
        let query = buildLookupQuery(account: account)
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        if status == errSecItemNotFound {
            logger.info("KeychainManager: элемент не найден для account=\(account, privacy: .public)")
            throw AppError(
                code: .auth(.credentialsMissing),
                description: L10n.Errors.Auth.credentialsMissingDescription,
                recoveryHint: L10n.Errors.Auth.credentialsMissingRecovery
            )
        }

        guard status == errSecSuccess else {
            logger.error("KeychainManager: загрузка не удалась для account=\(account, privacy: .public) status=\(status)")
            throw AppError(
                code: .auth(.keychainFailed),
                description: L10n.Errors.Auth.keychainFailedDescription,
                recoveryHint: L10n.Errors.Auth.keychainFailedRecovery,
                underlyingDescription: "OSStatus: \(status)"
            )
        }

        guard let data = result as? Data else {
            logger.error("KeychainManager: неожиданный формат данных для account=\(account, privacy: .public)")
            throw AppError(
                code: .auth(.keychainFailed),
                description: L10n.Errors.Auth.keychainFailedDescription,
                recoveryHint: L10n.Errors.Auth.keychainFailedRecovery,
                underlyingDescription: "Неожиданный формат данных из Keychain"
            )
        }

        return data
    }

    private func performDelete(account: String) throws {
        let query = buildDeleteQuery(account: account)
        let status = SecItemDelete(query as CFDictionary)
        if status == errSecItemNotFound {
            return
        }
        guard status == errSecSuccess else {
            logger.error("KeychainManager: удаление не удалось для account=\(account, privacy: .public) status=\(status)")
            throw AppError(
                code: .auth(.keychainFailed),
                description: L10n.Errors.Auth.keychainFailedDescription,
                recoveryHint: L10n.Errors.Auth.keychainFailedRecovery,
                underlyingDescription: "OSStatus: \(status)"
            )
        }
    }

    private func performExists(account: String) -> Bool {
        let query = buildExistsQuery(account: account)
        let status = SecItemCopyMatching(query as CFDictionary, nil)
        return status == errSecSuccess
    }
}