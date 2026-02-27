import XCTest
@testable import SupportKit

final class SupportKitTests: XCTestCase {

    func testConfigurationInitialization() {
        let config = Configuration(apiKey: "sk_test_123")

        XCTAssertEqual(config.apiKey, "sk_test_123")
        XCTAssertTrue(config.preferOnDevice)
        XCTAssertEqual(config.baseURL.absoluteString, "https://api.supportkit.dev")
    }

    func testConfigurationWithCustomURL() {
        let config = Configuration(
            apiKey: "sk_test_123",
            baseURL: URL(string: "https://custom.api.com")!
        )

        XCTAssertEqual(config.baseURL.absoluteString, "https://custom.api.com")
    }

    func testMessageCreation() {
        let message = Message(role: .user, content: "Hello")

        XCTAssertEqual(message.role, .user)
        XCTAssertEqual(message.content, "Hello")
        XCTAssertEqual(message.source, .unknown)
        XCTAssertFalse(message.isError)
    }

    func testMessageEquality() {
        let id = UUID()
        let message1 = Message(id: id, role: .user, content: "Hello")
        let message2 = Message(id: id, role: .user, content: "Hello")
        let message3 = Message(role: .user, content: "Hello")

        XCTAssertEqual(message1, message2)
        XCTAssertNotEqual(message1, message3)
    }

    func testThemeDefaults() {
        let theme = Theme.automatic

        XCTAssertEqual(theme.primaryColor, "#007AFF")
        XCTAssertNil(theme.fontName)
    }

    @available(iOS 17.0, macOS 14.0, *)
    @MainActor
    func testChatEngineInitialMessage() async {
        let config = Configuration(apiKey: "sk_test_123")
        let engine = ChatEngine(configuration: config)

        XCTAssertEqual(engine.messages.count, 1)
        XCTAssertEqual(engine.messages.first?.role, .assistant)
        XCTAssertFalse(engine.isProcessing)
    }

    @available(iOS 17.0, macOS 14.0, *)
    @MainActor
    func testChatEngineSendMessage() async {
        let config = Configuration(apiKey: "sk_test_123")
        let engine = ChatEngine(configuration: config)

        await engine.send("How do I reset my password?")

        // Should have: welcome + user message + assistant response
        XCTAssertEqual(engine.messages.count, 3)
        XCTAssertEqual(engine.messages[1].role, .user)
        XCTAssertEqual(engine.messages[1].content, "How do I reset my password?")
        XCTAssertEqual(engine.messages[2].role, .assistant)
    }

    @available(iOS 17.0, macOS 14.0, *)
    @MainActor
    func testChatEngineClearHistory() async {
        let config = Configuration(apiKey: "sk_test_123")
        let engine = ChatEngine(configuration: config)

        await engine.send("Test message")
        XCTAssertEqual(engine.messages.count, 3)

        engine.clearHistory()
        XCTAssertEqual(engine.messages.count, 1)
        XCTAssertEqual(engine.messages.first?.role, .assistant)
    }
}
