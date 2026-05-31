import Foundation
import os

// MARK: - LogLevel

enum LogLevel: String, Sendable {
    case debug, info, warning, error, fault
}

// MARK: - LogCategory

enum LogCategory: String, Sendable {
    case library, reader, cloud, ai, sync, storeKit, fileSystem, navigation, network
}

// MARK: - LogEntry

struct LogEntry: Sendable {
    let timestamp: Date
    let level: LogLevel
    let category: LogCategory
    let message: String
}

// MARK: - DiagnosticsService

actor DiagnosticsService {
    static let shared = DiagnosticsService()

    private let subsystem = Bundle.main.bundleIdentifier ?? "com.vreader"
    private var buffer: [LogEntry] = []
    private let bufferLimit = 100

    // Эвристические ключевые слова для фильтрации PII — первый слой защиты
    private static let piiKeywords = ["token", "password", "key", "secret"]

    // Известные статические KeychainKey для проверки через isSensitiveKey — второй слой защиты.
    // Ключи с ассоциированными значениями (webDAVPassword, smbPassword) покрываются
    // первым слоем containsPII через ключевое слово "password".
    private static let knownStaticKeychainKeys: [KeychainKey] = [
        .geminiAPIKey,
        .googleOAuthToken,
        .dropboxOAuthToken,
        .oneDriveOAuthToken
    ]

    private init() {}

    // MARK: - Публичный интерфейс

    /// Логирует событие с фильтрацией PII.
    func log(level: LogLevel, category: LogCategory, message: String) {
        guard !containsPII(message) else { return }
        let entry = LogEntry(timestamp: Date(), level: level, category: category, message: message)
        appendToBuffer(entry)
        emitToOSLog(entry)
    }

    /// Возвращает последние N записей из буфера (не более bufferLimit).
    func recentEntries(limit: Int = 100) -> [LogEntry] {
        let count = min(limit, buffer.count)
        return Array(buffer.suffix(count))
    }

    // MARK: - Приватные методы

    private func appendToBuffer(_ entry: LogEntry) {
        buffer.append(entry)
        if buffer.count > bufferLimit {
            buffer.removeFirst(buffer.count - bufferLimit)
        }
    }

    private func emitToOSLog(_ entry: LogEntry) {
        let logger = Logger(subsystem: subsystem, category: entry.category.rawValue)
        let msg = "\(entry.message)"
        switch entry.level {
        case .debug:   logger.debug("\(msg, privacy: .public)")
        case .info:    logger.info("\(msg, privacy: .public)")
        case .warning: logger.warning("\(msg, privacy: .public)")
        case .error:   logger.error("\(msg, privacy: .public)")
        case .fault:   logger.fault("\(msg, privacy: .public)")
        }
    }

    /// Первый слой защиты от PII: проверка по ключевым словам.
    private func containsPII(_ message: String) -> Bool {
        let lower = message.lowercased()
        return Self.piiKeywords.contains { lower.contains($0) }
    }

    /// Второй слой защиты: проверка по известным статическим ключам Keychain.
    private func isSensitiveKey(_ key: KeychainKey) -> Bool {
        Self.knownStaticKeychainKeys.contains { $0 == key }
    }
}