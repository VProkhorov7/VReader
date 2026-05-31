//
//  VreaderUITests.swift
//  VreaderUITests
//

import XCTest

final class VreaderUITests: XCTestCase {

    override func setUpWithError() throws {
        // Останавливаем тест при первой ошибке
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {}

    // MARK: - Существующий тест

    @MainActor
    func testExample() throws {
        let app = XCUIApplication()
        app.launch()
    }

    @MainActor
    func testLaunchPerformance() throws {
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }

    // MARK: - Интеграционные тесты NetworkMonitor

    /// Проверяет, что приложение успешно запускается с зарегистрированным NetworkMonitor.
    /// Косвенно подтверждает, что Environment ключ зарегистрирован и singleton инициализирован.
    @MainActor
    func testNetworkMonitorInitialized() throws {
        let app = XCUIApplication()
        app.launch()

        // Приложение должно запуститься без краша — это подтверждает корректную
        // инициализацию NetworkMonitor.shared и регистрацию EnvironmentKey.
        XCTAssertTrue(app.state == .runningForeground, "Приложение должно быть запущено в foreground")

        // Скриншот для визуальной проверки состояния UI при старте
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "NetworkMonitor — Состояние при запуске"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}