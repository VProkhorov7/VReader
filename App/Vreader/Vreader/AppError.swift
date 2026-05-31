import Foundation

/// Типизированная ошибка приложения с поддержкой локализации, аналитики и цепочки ошибок.
///
/// Поле `underlyingError` хранит исходную ошибку для runtime-контекста в async-коде,
/// но исключается из сериализации. Для сохранения контекста ошибки используется
/// `underlyingDescription: String?`.
///
/// Поле `underlyingError` имеет тип `(any Error & Sendable)?` для безопасного использования
/// в Swift Concurrency контексте.
struct AppError: Error, LocalizedError, Sendable, Codable {
    let code: ErrorCode
    let description: String
    let recoveryHint: String
    let underlyingError: (any Error & Sendable)?
    let underlyingDescription: String?

    var errorDescription: String? { description }
    var recoverySuggestion: String? { recoveryHint }

    /// Возвращает стабильный код ошибки в формате `"category.case"` без PII.
    var analyticsCode: String {
        "\(code.categoryName).\(code.caseName)"
    }

    init(
        code: ErrorCode,
        description: String,
        recoveryHint: String,
        underlyingError: (any Error & Sendable)? = nil,
        underlyingDescription: String? = nil
    ) {
        self.code = code
        self.description = description
        self.recoveryHint = recoveryHint
        self.underlyingError = underlyingError
        self.underlyingDescription = underlyingDescription
    }

    // MARK: - Codable

    private enum CodingKeys: String, CodingKey {
        case code
        case description
        case recoveryHint
        case underlyingDescription
    }

    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(code, forKey: .code)
        try container.encode(description, forKey: .description)
        try container.encode(recoveryHint, forKey: .recoveryHint)
        try container.encodeIfPresent(underlyingDescription, forKey: .underlyingDescription)
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        code = try container.decode(ErrorCode.self, forKey: .code)
        description = try container.decode(String.self, forKey: .description)
        recoveryHint = try container.decode(String.self, forKey: .recoveryHint)
        underlyingDescription = try container.decodeIfPresent(String.self, forKey: .underlyingDescription)
        underlyingError = nil
    }

    // MARK: - Factory Methods

    static func fileNotFound(path: String) -> AppError {
        AppError(
            code: .fileSystem(.fileNotFound),
            description: L10n.Errors.FileSystem.fileNotFoundDescription,
            recoveryHint: L10n.Errors.FileSystem.fileNotFoundRecovery
        )
    }

    static func networkUnavailable() -> AppError {
        AppError(
            code: .network(.unavailable),
            description: L10n.Errors.Network.unavailableDescription,
            recoveryHint: L10n.Errors.Network.unavailableRecovery
        )
    }

    static func premiumRequired(feature: String) -> AppError {
        AppError(
            code: .storeKit(.premiumRequired),
            description: L10n.Errors.StoreKit.premiumRequiredDescription,
            recoveryHint: L10n.Errors.StoreKit.premiumRequiredRecovery
        )
    }

    static func timeout(service: String) -> AppError {
        AppError(
            code: .network(.timeout),
            description: L10n.Errors.Network.timeoutDescription,
            recoveryHint: L10n.Errors.Network.timeoutRecovery
        )
    }
}