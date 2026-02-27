import Foundation

/// Configuration options for SupportKit
public struct Configuration {

    /// Your SupportKit API key
    public let apiKey: String

    /// Base URL for the SupportKit backend (defaults to production)
    public let baseURL: URL

    /// Theme customization
    public var theme: Theme

    /// Whether to prefer on-device processing when available
    public var preferOnDevice: Bool

    /// Escalation configuration
    public var escalation: EscalationConfig

    /// Creates a new configuration
    /// - Parameters:
    ///   - apiKey: Your SupportKit API key
    ///   - baseURL: Custom backend URL (optional)
    ///   - theme: UI theme customization
    ///   - preferOnDevice: Use Apple Intelligence when available (default: true)
    public init(
        apiKey: String,
        baseURL: URL = URL(string: "https://api.appsupportsdk.com")!,
        theme: Theme = .automatic,
        preferOnDevice: Bool = true,
        escalation: EscalationConfig = .default
    ) {
        self.apiKey = apiKey
        self.baseURL = baseURL
        self.theme = theme
        self.preferOnDevice = preferOnDevice
        self.escalation = escalation
    }
}

// MARK: - Theme

public struct Theme {
    public var primaryColor: String  // Hex color
    public var backgroundColor: String
    public var userBubbleColor: String
    public var assistantBubbleColor: String
    public var fontName: String?

    public static let automatic = Theme(
        primaryColor: "#007AFF",
        backgroundColor: "#FFFFFF",
        userBubbleColor: "#007AFF",
        assistantBubbleColor: "#E9E9EB",
        fontName: nil
    )

    public static let dark = Theme(
        primaryColor: "#0A84FF",
        backgroundColor: "#1C1C1E",
        userBubbleColor: "#0A84FF",
        assistantBubbleColor: "#2C2C2E",
        fontName: nil
    )
}

// MARK: - Escalation

public struct EscalationConfig {
    public enum Method {
        case email(address: String)
        case url(URL)
        case callback(() -> Void)
    }

    public var method: Method?
    public var promptText: String

    public static let `default` = EscalationConfig(
        method: nil,
        promptText: "Would you like to speak with our support team?"
    )

    public init(method: Method?, promptText: String) {
        self.method = method
        self.promptText = promptText
    }
}
