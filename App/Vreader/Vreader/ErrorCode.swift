import Foundation

// MARK: - FileSystemError

enum FileSystemError: String, Equatable, Hashable, Codable, Sendable, CaseIterable {
    case fileNotFound
    case permissionDenied
    case bookmarkStale
    case diskFull
    case readFailed
    case writeFailed
    case deleteFailed
    case moveFailed
    case copyFailed
    case createDirectoryFailed
    case invalidPath
    case fileAlreadyExists
    case fileAccessDenied
}

// MARK: - NetworkError

enum NetworkError: String, Equatable, Hashable, Codable, Sendable, CaseIterable {
    case unavailable
    case offline
    case timeout
    case cancelled
    case invalidResponse
    case invalidStatusCode
    case requestFailed
    case downloadFailed
    case uploadFailed
    case decodingFailed
    case encodingFailed
    case rateLimited
    case serverError
}

// MARK: - CloudProviderError

enum CloudProviderError: String, Equatable, Hashable, Codable, Sendable, CaseIterable {
    case providerUnavailable
    case credentialsMissing
    case authenticationFailed
    case authorizationFailed
    case accountNotFound
    case resourceNotFound
    case quotaExceeded
    case conflict
    case invalidResponse
    case unsupportedProvider
    case syncFailed
    case downloadFailed
    case uploadFailed
}

// MARK: - AIServiceError

enum AIServiceError: String, Equatable, Hashable, Codable, Sendable, CaseIterable {
    case apiKeyMissing
    case apiKeyInvalid
    case requestFailed
    case invalidResponse
    case rateLimited
    case quotaExceeded
    case modelUnavailable
    case contentBlocked
    case unsupportedLanguage
    case generationFailed
    case timeout
}

// MARK: - StoreKitError

enum StoreKitError: String, Equatable, Hashable, Codable, Sendable, CaseIterable {
    case productNotFound
    case purchaseFailed
    case purchaseCancelled
    case verificationFailed
    case premiumRequired
    case restoreFailed
    case receiptMissing
    case receiptInvalid
    case notEntitled
}

// MARK: - SyncError

enum SyncError: String, Equatable, Hashable, Codable, Sendable, CaseIterable {
    case conflictDetected
    case mergeFailed
    case cloudUnavailable
    case pushFailed
    case pullFailed
    case invalidState
    case versionMismatch
    case serializationFailed
    case deserializationFailed
}

// MARK: - ParsingError

enum ParsingError: String, Equatable, Hashable, Codable, Sendable, CaseIterable {
    case unsupportedFormat
    case invalidFormat
    case corruptedData
    case missingRequiredField
    case decodingFailed
    case encodingFailed
    case emptyContent
    case unsupportedEncoding
    case metadataExtractionFailed
}

// MARK: - AuthError

enum AuthError: String, Equatable, Hashable, Codable, Sendable, CaseIterable {
    case credentialsMissing
    case invalidCredentials
    case tokenExpired
    case tokenMissing
    case refreshFailed
    case accessDenied
    case sessionExpired
    case biometryUnavailable
    case biometryFailed
    case keychainFailed
}

// MARK: - ErrorCode

enum ErrorCode: Error, Equatable, Hashable, Sendable, Codable {
    case fileSystem(FileSystemError)
    case network(NetworkError)
    case cloudProvider(CloudProviderError)
    case aiService(AIServiceError)
    case storeKit(StoreKitError)
    case sync(SyncError)
    case parsing(ParsingError)
    case auth(AuthError)

    // MARK: Coding

    private enum CodingKeys: String, CodingKey {
        case category
        case value
    }

    private enum Category: String, Codable {
        case fileSystem
        case network
        case cloudProvider
        case aiService
        case storeKit
        case sync
        case parsing
        case auth
    }

    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .fileSystem(let e):
            try container.encode(Category.fileSystem, forKey: .category)
            try container.encode(e, forKey: .value)
        case .network(let e):
            try container.encode(Category.network, forKey: .category)
            try container.encode(e, forKey: .value)
        case .cloudProvider(let e):
            try container.encode(Category.cloudProvider, forKey: .category)
            try container.encode(e, forKey: .value)
        case .aiService(let e):
            try container.encode(Category.aiService, forKey: .category)
            try container.encode(e, forKey: .value)
        case .storeKit(let e):
            try container.encode(Category.storeKit, forKey: .category)
            try container.encode(e, forKey: .value)
        case .sync(let e):
            try container.encode(Category.sync, forKey: .category)
            try container.encode(e, forKey: .value)
        case .parsing(let e):
            try container.encode(Category.parsing, forKey: .category)
            try container.encode(e, forKey: .value)
        case .auth(let e):
            try container.encode(Category.auth, forKey: .category)
            try container.encode(e, forKey: .value)
        }
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let category = try container.decode(Category.self, forKey: .category)
        switch category {
        case .fileSystem:
            self = .fileSystem(try container.decode(FileSystemError.self, forKey: .value))
        case .network:
            self = .network(try container.decode(NetworkError.self, forKey: .value))
        case .cloudProvider:
            self = .cloudProvider(try container.decode(CloudProviderError.self, forKey: .value))
        case .aiService:
            self = .aiService(try container.decode(AIServiceError.self, forKey: .value))
        case .storeKit:
            self = .storeKit(try container.decode(StoreKitError.self, forKey: .value))
        case .sync:
            self = .sync(try container.decode(SyncError.self, forKey: .value))
        case .parsing:
            self = .parsing(try container.decode(ParsingError.self, forKey: .value))
        case .auth:
            self = .auth(try container.decode(AuthError.self, forKey: .value))
        }
    }

    // MARK: Analytics Code

    var categoryName: String {
        switch self {
        case .fileSystem: return "fileSystem"
        case .network: return "network"
        case .cloudProvider: return "cloudProvider"
        case .aiService: return "aiService"
        case .storeKit: return "storeKit"
        case .sync: return "sync"
        case .parsing: return "parsing"
        case .auth: return "auth"
        }
    }

    var caseName: String {
        switch self {
        case .fileSystem(let e): return e.rawValue
        case .network(let e): return e.rawValue
        case .cloudProvider(let e): return e.rawValue
        case .aiService(let e): return e.rawValue
        case .storeKit(let e): return e.rawValue
        case .sync(let e): return e.rawValue
        case .parsing(let e): return e.rawValue
        case .auth(let e): return e.rawValue
        }
    }
}