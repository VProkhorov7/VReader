import Foundation
import Network
import Observation

// MARK: - ConnectionType

enum ConnectionType {
    case wifi
    case cellular
    case wiredEthernet
    case unknown
}

// MARK: - NetworkMonitor

/// Единственный источник истины о состоянии сети.
/// @Observable singleton, работает на MainActor.
/// isOnline инициализируется как false, реальное значение — при первом pathUpdateHandler callback.
@Observable
@MainActor
final class NetworkMonitor {

    // MARK: - Singleton

    static let shared = NetworkMonitor()

    // MARK: - Публичные свойства

    /// Текущее состояние сети. false до первого callback от NWPathMonitor.
    private(set) var isOnline: Bool = false

    /// Тип активного соединения. Определяется по path.availableInterfaces.first?.type.
    private(set) var connectionType: ConnectionType = .unknown

    /// true если соединение cellular — для ограничения фоновых загрузок.
    var isExpensive: Bool { connectionType == .cellular }

    // MARK: - Приватные свойства

    /// Опциональная ссылка — обнуляется при stopMonitoring().
    private var monitor: NWPathMonitor?
    private let queue = DispatchQueue(label: "com.vreader.network-monitor", qos: .utility)

    // MARK: - Инициализация

    private init() {
        startMonitoring()
    }

    // MARK: - Жизненный цикл

    /// Создаёт новый NWPathMonitor при каждом вызове.
    /// Старый монитор корректно останавливается перед заменой.
    func startMonitoring() {
        // Останавливаем предыдущий экземпляр, если есть
        monitor?.cancel()
        monitor = nil

        let newMonitor = NWPathMonitor()

        newMonitor.pathUpdateHandler = { [weak self] path in
            guard let self else { return }

            let newIsOnline = path.status == .satisfied
            let newConnectionType = Self.resolveConnectionType(from: path)

            // Все мутации @Observable свойств — строго на MainActor
            Task {
                await MainActor.run(resultType: Void.self) {
                    let previousIsOnline = self.isOnline
                    self.connectionType = newConnectionType
                    self.isOnline = newIsOnline

                    // Логируем только переходы состояния isOnline
                    if previousIsOnline != newIsOnline {
                        self.logStateTransition(from: previousIsOnline, to: newIsOnline)
                    }
                }
            }
        }

        newMonitor.start(queue: queue)
        monitor = newMonitor
    }

    /// Останавливает монитор и обнуляет ссылку (нет утечек памяти).
    func stopMonitoring() {
        monitor?.cancel()
        monitor = nil
    }

    // MARK: - Логирование переходов

    /// Вызывается только при изменении isOnline (false→true или true→false).
    private func logStateTransition(from oldValue: Bool, to newValue: Bool) {
        let event = newValue ? "network_online" : "network_offline"
        Task {
            await DiagnosticsService.shared.log(
                level: .info,
                category: .network,
                message: event
            )
        }
    }

    // MARK: - Приватные утилиты

    /// Определяет тип соединения по первому доступному интерфейсу.
    private static func resolveConnectionType(from path: NWPath) -> ConnectionType {
        guard let interface = path.availableInterfaces.first else { return .unknown }
        switch interface.type {
        case .wifi:          return .wifi
        case .cellular:      return .cellular
        case .wiredEthernet: return .wiredEthernet
        default:             return .unknown
        }
    }
}