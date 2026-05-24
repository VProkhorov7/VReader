import Foundation
import os

enum LogLevel: String, Sendable {
    case debug, info, warning, error, fault
}

enum LogCategory: String, Sendable {
    case library, reader, cloud, ai, sync, storeKit, fileSystem, navigation
}

struct LogEntry: Sendable {
    let timestamp: Date
    let level: LogLevel
    let category: LogCategory
    let message: String
}

actor DiagnosticsService {
    static let shared = DiagnosticsService()

    private let subsystem = Bundle.main.bundleIdentifier ?? "com.vreader"
    private var buffer: [LogEntry] = []
    private let bufferLimit = 100

    private static let piiKeywords = ["token", "password", "key", "secret"]

    private init() {}

    func debug(_ message: String, category: LogCategory) {
        #if DEBUG
        log(message, level: .debug, category: category)
        #endif
    }

    func info(_ message: String, category: LogCategory) {
        log(message, level: .info, category: category)
    }

    func warning(_ message: String, category: LogCategory) {
        log(message, level: .warning, category: category)
    }

    func error(_ error: AppError, context: String) {
        let message = "[\(context)] \(error.localizedDescription)"
        log(message, level: .error, category: .library)
    }

    func fault(_ message: String, category: LogCategory) {
        log(message, level: .fault, category: category)
    }

    func exportLogs() -> String {
        let formatter = ISO8601DateFormatter()
        return buffer.map { entry in
            "[\(formatter.string(from: entry.timestamp))] [\(entry.level.rawValue.uppercased())] [\(entry.category.rawValue)] \(entry.message)"
        }.joined(separator: "\n")
    }

    private func log(_ message: String, level: LogLevel, category: LogCategory) {
        guard !Self.containsPII(message) else { return }

        let logger = Logger(subsystem: subsystem, category: category.rawValue)
        switch level {
        case .debug:   logger.debug("\(message, privacy: .public)")
        case .info:    logger.info("\(message, privacy: .public)")
        case .warning: logger.warning("\(message, privacy: .public)")
        case .error:   logger.error("\(message, privacy: .public)")
        case .fault:   logger.fault("\(message, privacy: .public)")
        }

        #if !DEBUG
        guard level == .warning || level == .error || level == .fault else { return }
        #endif

        let entry = LogEntry(timestamp: Date(), level: level, category: category, message: message)
        buffer.append(entry)
        if buffer.count > bufferLimit {
            buffer.removeFirst(buffer.count - bufferLimit)
        }
    }

    private static func containsPII(_ message: String) -> Bool {
        let lower = message.lowercased()
        return piiKeywords.contains { lower.contains($0) }
    }
}
