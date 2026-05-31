import SwiftUI

// MARK: - NetworkMonitorKey

/// EnvironmentKey для доступа к NetworkMonitor из любой View через @Environment.
private struct NetworkMonitorKey: EnvironmentKey {
    static let defaultValue: NetworkMonitor = NetworkMonitor.shared
}

// MARK: - EnvironmentValues + networkMonitor

extension EnvironmentValues {
    /// Доступ: @Environment(\.networkMonitor) var networkMonitor
    var networkMonitor: NetworkMonitor {
        get { self[NetworkMonitorKey.self] }
        set { self[NetworkMonitorKey.self] = newValue }
    }
}