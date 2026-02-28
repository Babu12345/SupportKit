import Foundation

/// Handles communication with the SupportKit backend
final class APIClient {

    private let configuration: Configuration
    private let session: URLSession

    init(configuration: Configuration) {
        self.configuration = configuration
        self.session = URLSession.shared
    }

    // MARK: - Chat

    /// Send a chat message and get a response
    func chat(messages: [Message], query: String) async throws -> String {
        // Use real backend, fall back to mock in DEBUG if backend unavailable
        do {
            return try await performChatRequest(messages: messages, query: query)
        } catch {
            #if DEBUG
            print("SupportKit: Backend request failed (\(error)), using mock response")
            return try await mockChatResponse(query: query)
            #else
            throw error
            #endif
        }
    }

    // MARK: - Knowledge Sync

    /// Fetch the latest knowledge bundle
    func fetchKnowledgeBundle() async throws -> KnowledgeBundle {
        let url = configuration.baseURL.appendingPathComponent("v1/knowledge/bundle")

        var request = URLRequest(url: url)
        request.setValue("Bearer \(configuration.apiKey)", forHTTPHeaderField: "Authorization")

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw APIError.invalidResponse
        }

        return try JSONDecoder().decode(KnowledgeBundle.self, from: data)
    }

    // MARK: - Private

    private func performChatRequest(messages: [Message], query: String) async throws -> String {
        let url = configuration.baseURL.appendingPathComponent("v1/chat")

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(configuration.apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body = ChatRequest(
            messages: messages.map { ChatMessage(role: $0.role.rawValue, content: $0.content) },
            query: query
        )
        request.httpBody = try JSONEncoder().encode(body)

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        switch httpResponse.statusCode {
        case 200:
            let chatResponse = try JSONDecoder().decode(ChatResponse.self, from: data)
            return chatResponse.content
        case 401:
            throw APIError.unauthorized
        case 429:
            // Check if this is a conversation limit error
            if let errorResponse = try? JSONDecoder().decode(LimitErrorResponse.self, from: data),
               errorResponse.limitReached {
                throw APIError.conversationLimitReached
            }
            throw APIError.rateLimited
        default:
            throw APIError.serverError(statusCode: httpResponse.statusCode)
        }
    }

    // MARK: - Mock Responses (Development)

    #if DEBUG
    private func mockChatResponse(query: String) async throws -> String {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds

        let lowercased = query.lowercased()

        // Simple keyword matching for demo
        if lowercased.contains("password") || lowercased.contains("reset") {
            return "To reset your password, go to Settings > Account > Change Password. If you've forgotten your password, tap \"Forgot Password\" on the login screen and we'll email you a reset link."
        }

        if lowercased.contains("cancel") || lowercased.contains("subscription") {
            return "To cancel your subscription, go to Settings > Subscription > Manage, then tap \"Cancel Subscription\". You'll keep access until the end of your billing period."
        }

        if lowercased.contains("refund") {
            return "We offer a 30-day money-back guarantee. Contact us at support@acme.app with your account email and we'll process your refund within 3-5 business days."
        }

        if lowercased.contains("dark mode") || lowercased.contains("theme") {
            return "To enable dark mode, go to Settings > Appearance > Theme and select \"Dark\". You can also choose \"System\" to match your device settings."
        }

        if lowercased.contains("delete") && lowercased.contains("account") {
            return "To delete your account, go to Settings > Account > Delete Account, enter your password, and tap \"Delete Forever\". Note: This action is permanent and cannot be undone."
        }

        if lowercased.contains("export") || lowercased.contains("data") {
            return "To export your data, go to Settings > Data > Export. Choose your format (JSON or CSV) and tap \"Export\". We'll email you a download link within 24 hours."
        }

        if lowercased.contains("upgrade") || lowercased.contains("pro") {
            return "To upgrade to Pro, go to Settings > Subscription > Upgrade to Pro. You can choose monthly ($9.99/month) or yearly ($99.99/year, save 17%)."
        }

        // Fallback for unknown queries
        return "I don't have specific information about that in my knowledge base. Would you like me to connect you with our support team at support@acme.app?"
    }
    #endif
}

// MARK: - Request/Response Types

private struct ChatRequest: Encodable {
    let messages: [ChatMessage]
    let query: String
}

private struct ChatMessage: Codable {
    let role: String
    let content: String
}

private struct ChatResponse: Decodable {
    let content: String
    let source: String?
}

// MARK: - Errors

enum APIError: Error, LocalizedError {
    case invalidResponse
    case unauthorized
    case rateLimited
    case conversationLimitReached
    case serverError(statusCode: Int)

    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Invalid response from server"
        case .unauthorized:
            return "Invalid API key"
        case .rateLimited:
            return "Too many requests. Please try again later."
        case .conversationLimitReached:
            return "This organization has reached its monthly conversation limit. Please try again later."
        case .serverError(let code):
            return "Server error (code: \(code))"
        }
    }
}

private struct LimitErrorResponse: Decodable {
    let limitReached: Bool

    enum CodingKeys: String, CodingKey {
        case limitReached = "limit_reached"
    }
}
