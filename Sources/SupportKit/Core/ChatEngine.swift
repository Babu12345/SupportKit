import Foundation
import SwiftUI

/// Handles message processing and response generation
@available(iOS 17.0, macOS 14.0, *)
@Observable
@MainActor
public final class ChatEngine {

    /// All messages in the conversation
    public private(set) var messages: [Message] = []

    /// Whether a response is being generated
    public private(set) var isProcessing: Bool = false

    /// Configuration
    private let configuration: Configuration

    /// On-device processor (when available)
    private var onDeviceProcessor: OnDeviceProcessor?

    /// API client for cloud fallback
    private let apiClient: APIClient

    /// Local knowledge cache
    private var knowledgeCache: KnowledgeCache

    init(configuration: Configuration) {
        self.configuration = configuration
        self.apiClient = APIClient(configuration: configuration)
        self.knowledgeCache = KnowledgeCache()

        // Initialize on-device processor if available and preferred
        if configuration.preferOnDevice {
            self.onDeviceProcessor = OnDeviceProcessor()
        }

        // Add welcome message
        messages.append(Message(
            role: .assistant,
            content: "Hi! I'm here to help. What can I assist you with today?"
        ))
    }

    // MARK: - Public API

    /// Send a message and get a response
    /// - Parameter content: The user's message
    public func send(_ content: String) async {
        let userMessage = Message(role: .user, content: content)
        messages.append(userMessage)

        isProcessing = true
        defer { isProcessing = false }

        do {
            let response = try await generateResponse(for: content)
            messages.append(response)
        } catch {
            messages.append(Message(
                role: .assistant,
                content: "I'm having trouble responding right now. Would you like to contact our support team directly?",
                isError: true
            ))
        }
    }

    /// Clear conversation history
    public func clearHistory() {
        messages = [Message(
            role: .assistant,
            content: "Hi! I'm here to help. What can I assist you with today?"
        )]
    }

    // MARK: - Private

    private func generateResponse(for query: String) async throws -> Message {
        // Try on-device first if available
        if let processor = onDeviceProcessor,
           let localResponse = await processor.process(
               query: query,
               knowledge: knowledgeCache.content
           ) {
            return Message(
                role: .assistant,
                content: localResponse,
                source: .onDevice
            )
        }

        // Fall back to cloud
        let response = try await apiClient.chat(
            messages: messages,
            query: query
        )

        return Message(
            role: .assistant,
            content: response,
            source: .cloud
        )
    }
}
