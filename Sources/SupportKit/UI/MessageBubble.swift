import SwiftUI

/// A single message bubble
struct MessageBubble: View {
    let message: Message

    private var isUser: Bool {
        message.role == .user
    }

    private var markdownContent: AttributedString {
        (try? AttributedString(markdown: message.content, options: .init(interpretedSyntax: .inlineOnlyPreservingWhitespace))) ?? AttributedString(message.content)
    }

    var body: some View {
        HStack {
            if isUser { Spacer(minLength: 60) }

            VStack(alignment: isUser ? .trailing : .leading, spacing: 4) {
                Text(isUser ? AttributedString(message.content) : markdownContent)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(bubbleBackground)
                    .foregroundStyle(isUser ? .white : .primary)
                    .clipShape(RoundedRectangle(cornerRadius: 18))

                // Source indicator (debug mode only)
                #if DEBUG
                if message.source != .unknown {
                    Text(message.source == .onDevice ? "on-device" : "cloud")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
                #endif
            }

            if !isUser { Spacer(minLength: 60) }
        }
    }

    private var bubbleBackground: some ShapeStyle {
        if message.isError {
            return AnyShapeStyle(Color.red.opacity(0.2))
        }
        if isUser {
            return AnyShapeStyle(Color.accentColor)
        }
        #if canImport(UIKit)
        return AnyShapeStyle(Color(.secondarySystemBackground))
        #else
        return AnyShapeStyle(Color.gray.opacity(0.2))
        #endif
    }
}

#Preview {
    VStack(spacing: 12) {
        MessageBubble(message: Message(
            role: .user,
            content: "How do I reset my password?"
        ))

        MessageBubble(message: Message(
            role: .assistant,
            content: "To reset your password, go to Settings > Account > Change Password. You'll need to enter your current password first.",
            source: .onDevice
        ))

        MessageBubble(message: Message(
            role: .assistant,
            content: "I'm having trouble connecting right now.",
            isError: true
        ))
    }
    .padding()
}
