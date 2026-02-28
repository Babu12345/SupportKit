import SwiftUI

/// Main chat interface view
@available(iOS 17.0, macOS 14.0, *)
public struct ChatView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var engine: ChatEngine
    @State private var inputText: String = ""
    @State private var hasConsented = DataConsentManager.hasConsented
    @State private var showConsentSheet = false
    @FocusState private var isInputFocused: Bool

    init(engine: ChatEngine) {
        self._engine = State(initialValue: engine)
    }

    public var body: some View {
        VStack(spacing: 0) {
            // Header
            ChatHeader()

            // Messages
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(engine.messages) { message in
                            MessageBubble(message: message)
                                .id(message.id)
                        }

                        if engine.isProcessing {
                            TypingIndicator()
                                .id("typing")
                        }
                    }
                    .padding()
                }
                .onChange(of: engine.messages.count) { _, _ in
                    scrollToBottom(proxy: proxy)
                }
                .onChange(of: engine.isProcessing) { _, _ in
                    scrollToBottom(proxy: proxy)
                }
            }

            // Input bar
            InputBar(
                text: $inputText,
                isProcessing: engine.isProcessing || !hasConsented,
                onSend: sendMessage
            )
            .focused($isInputFocused)
        }
        #if canImport(UIKit)
        .background(Color(.systemBackground))
        #else
        .background(.background)
        #endif
        .onAppear {
            if !hasConsented {
                showConsentSheet = true
            }
        }
        .sheet(isPresented: $showConsentSheet) {
            DataConsentView(
                onAgree: {
                    DataConsentManager.setConsented()
                    hasConsented = true
                    showConsentSheet = false
                },
                onCancel: {
                    showConsentSheet = false
                    dismiss()
                }
            )
        }
    }

    private func sendMessage() {
        let text = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }

        inputText = ""

        Task {
            await engine.send(text)
        }
    }

    private func scrollToBottom(proxy: ScrollViewProxy) {
        withAnimation(.easeOut(duration: 0.2)) {
            if engine.isProcessing {
                proxy.scrollTo("typing", anchor: .bottom)
            } else if let lastMessage = engine.messages.last {
                proxy.scrollTo(lastMessage.id, anchor: .bottom)
            }
        }
    }
}

// MARK: - Chat Header

struct ChatHeader: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                // SupportKit logo
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.accentColor)
                        .frame(width: 40, height: 40)
                    Image(systemName: "bubble.left.and.bubble.right.fill")
                        .font(.system(size: 18))
                        .foregroundStyle(.white)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text("Support")
                        .font(.headline)
                    Text("Instant AI assistance")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 14)

            // Powered by link
            Link(destination: URL(string: "https://www.appsupportsdk.com")!) {
                HStack(spacing: 4) {
                    Text("Powered by")
                        .foregroundStyle(.secondary)
                    Text("SupportKit")
                        .foregroundStyle(Color.accentColor)
                        .fontWeight(.medium)
                }
                .font(.caption2)
                .padding(.bottom, 8)
            }
        }
        #if canImport(UIKit)
        .background(Color(.systemBackground))
        #else
        .background(.background)
        #endif
        .overlay(alignment: .bottom) {
            Divider()
        }
    }
}

// MARK: - Typing Indicator

struct TypingIndicator: View {
    @State private var dotCount = 0

    var body: some View {
        HStack {
            HStack(spacing: 4) {
                ForEach(0..<3) { index in
                    Circle()
                        .fill(Color.secondary)
                        .frame(width: 8, height: 8)
                        .opacity(dotCount == index ? 1 : 0.4)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            #if canImport(UIKit)
            .background(Color(.secondarySystemBackground))
            #else
            .background(Color.gray.opacity(0.2))
            #endif
            .clipShape(RoundedRectangle(cornerRadius: 18))

            Spacer()
        }
        .onAppear {
            startAnimation()
        }
    }

    private func startAnimation() {
        Timer.scheduledTimer(withTimeInterval: 0.3, repeats: true) { _ in
            dotCount = (dotCount + 1) % 3
        }
    }
}

@available(iOS 17.0, macOS 14.0, *)
#Preview {
    ChatView(engine: ChatEngine(configuration: Configuration(apiKey: "test")))
}
