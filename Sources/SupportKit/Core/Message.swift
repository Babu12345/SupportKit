import Foundation

/// A chat message
public struct Message: Identifiable, Equatable {
    public let id: UUID
    public let role: Role
    public let content: String
    public let timestamp: Date
    public let source: Source
    public let isError: Bool

    public enum Role: String, Codable {
        case user
        case assistant
    }

    public enum Source: String, Codable {
        case onDevice
        case cloud
        case unknown
    }

    public init(
        id: UUID = UUID(),
        role: Role,
        content: String,
        timestamp: Date = Date(),
        source: Source = .unknown,
        isError: Bool = false
    ) {
        self.id = id
        self.role = role
        self.content = content
        self.timestamp = timestamp
        self.source = source
        self.isError = isError
    }

    public static func == (lhs: Message, rhs: Message) -> Bool {
        lhs.id == rhs.id
    }
}
